function generate_dependency_list(entryFile, searchRoot)
% GENERATE_DEPENDENCY_LIST  Reproduce the required-files/toolboxes analysis
% used to build this repo's src/ folder.
%
%   generate_dependency_list()                      % analyze this repo's own src/
%   generate_dependency_list(entryFile, searchRoot)  % analyze any entry file
%
% Wraps matlab.codetools.requiredFilesAndProducts. Re-run this after editing
% CLASS_photometry_roadmapv1_4.m (or pointed at the original messy source
% tree) to check whether the required-file list has changed.
%
% Note: if searchRoot contains syntactically broken .m files (stray scratch
% files, editor autosaves, etc.), requiredFilesAndProducts will error out
% entirely rather than skip them — exclude such files from searchRoot first.

    if nargin < 1
        thisDir = fileparts(mfilename('fullpath'));
        searchRoot = fullfile(thisDir, '..', 'src');
        entryFile = fullfile(searchRoot, 'CLASS_photometry_roadmapv1_4.m');
    end

    oldPath = path();
    cleanupObj = onCleanup(@() path(oldPath));
    addpath(genpath(searchRoot));

    [files, products] = matlab.codetools.requiredFilesAndProducts(entryFile);

    fprintf('=== Required files (%d) ===\n', numel(files));
    for i = 1:numel(files)
        fprintf('%s\n', files{i});
    end

    fprintf('\n=== Required toolboxes (%d, per requiredFilesAndProducts) ===\n', numel(products));
    for i = 1:numel(products)
        fprintf('%s\n', products(i).Name);
    end
    fprintf(['\nNote: requiredFilesAndProducts'' toolbox detection is not fully reliable\n' ...
             '(e.g. it has been observed to miss Signal Processing Toolbox despite lowpass()\n' ...
             'being called). Cross-check with a manual grep for toolbox-specific functions.\n']);
end
