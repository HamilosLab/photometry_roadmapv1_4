%% generate_api_json.m
%
%   Regenerates docs/api-data.json for the searchable API documentation
%   site (GitHub Pages, served from docs/).
%
%   Run from anywhere (paths below are resolved relative to this file):
%       matlab -batch "run('tools/docgen/generate_api_json.m')"
%
%   All MATLAB-syntax-aware extraction is delegated to MATLAB's own
%   introspection (meta.class, help) rather than a hand-rolled parser --
%   see the "Searchable API documentation" section in README.md for why.

thisDir  = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(thisDir));
srcDir   = fullfile(repoRoot, 'src');
docsDir  = fullfile(repoRoot, 'docs');

addpath(srcDir);

className = 'CLASS_photometry_roadmapv1_4';
mc = meta.class.fromName(className);
if isempty(mc)
    error('generate_api_json:classNotFound', ...
        '%s not found on path -- check srcDir: %s', className, srcDir);
end

classInfo = struct();
classInfo.name = mc.Name;
classInfo.properties = extractProperties(mc, className);
classInfo.methods = extractMethods(mc, className);

functionsInfo = extractStandaloneFunctions(srcDir, className);

data = struct();
data.class = classInfo;
data.functions = functionsInfo;

if ~isfolder(docsDir)
    mkdir(docsDir);
end
outFile = fullfile(docsDir, 'api-data.json');
fid = fopen(outFile, 'w');
if fid == -1
    error('generate_api_json:writeFailed', 'Could not open %s for writing', outFile);
end
fprintf(fid, '%s', jsonencode(data, 'PrettyPrint', true));
fclose(fid);

fprintf('Wrote %s (%d properties, %d methods, %d standalone functions)\n', ...
    outFile, numel(classInfo.properties), numel(classInfo.methods), numel(functionsInfo));

%% Local functions

function props = extractProperties(mc, className)
    props = struct('name', {}, 'description', {});
    for i = 1:numel(mc.PropertyList)
        p = mc.PropertyList(i);
        % handle (the superclass) contributes no public properties for this
        % class today, but skip anything not declared directly on the class
        % in case that ever changes.
        if ~strcmp(p.DefiningClass.Name, className)
            continue
        end
        props(end+1) = struct( ...
            'name', p.Name, ...
            'description', combineDescription(p.Description, p.DetailedDescription)); %#ok<AGROW>
    end
end

function methodsOut = extractMethods(mc, className)
    methodsOut = struct('name', {}, 'signature', {}, 'description', {});
    for i = 1:numel(mc.MethodList)
        m = mc.MethodList(i);
        % handle (the superclass) contributes inherited methods such as
        % addlistener/delete/findobj/isvalid/notify/eq/ne -- exclude those,
        % keeping only methods actually defined in this classdef.
        if ~strcmp(m.DefiningClass.Name, className)
            continue
        end
        methodsOut(end+1) = struct( ...
            'name', m.Name, ...
            'signature', buildSignature(m), ...
            'description', combineDescription(m.Description, m.DetailedDescription)); %#ok<AGROW>
    end
end

function sig = buildSignature(m)
    inputs = m.InputNames;
    if ~isempty(inputs) && strcmp(inputs{1}, 'obj')
        inputs = inputs(2:end);
    end
    sig = sprintf('%s(%s)', m.Name, strjoin(inputs, ', '));
end

function text = combineDescription(shortDesc, detailedDesc)
    % Many comment blocks in this codebase open with a lone "%" line before
    % the real content. MATLAB's H1 convention treats that blank first line
    % as an empty Description, pushing the real text into
    % DetailedDescription -- so combine both rather than showing Description
    % alone, or the site will look far less documented than it actually is.
    text = strtrim(sprintf('%s %s', shortDesc, detailedDesc));
end

function funcs = extractStandaloneFunctions(srcDir, classFileNameNoExt)
    funcs = struct('file', {}, 'name', {}, 'description', {});
    files = dir(fullfile(srcDir, '*.m'));
    for i = 1:numel(files)
        [~, name] = fileparts(files(i).name);
        if strcmp(name, classFileNameNoExt)
            continue
        end
        helpText = strtrim(help(name));
        funcs(end+1) = struct('file', files(i).name, 'name', name, 'description', helpText); %#ok<AGROW>
    end
end
