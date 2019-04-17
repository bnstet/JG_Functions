function pathtofile = path2file()
% path2file Path to a given file
%   pathtofile = path2file() returns the full path to the file in which it
%   is called, excluding the file name.
%   
%   Jon Gill 2019
pathtofile = mfilename('fullpath')
filename = mfilename
pathtofile = pathtofile(1:end-length(filename))
end