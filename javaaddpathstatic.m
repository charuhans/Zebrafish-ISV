function javaaddpathstatic(file)
%JAVAADDPATHSTATIC Add an entry to the static classpath at run time
%
% javaaddpathstatic(file)
%
% Adds the given file to the STATIC classpath. This is in contrast to the
% regular javaaddpath, which adds a file to the dynamic classpath.
%
% Files added to the path will not show up in the output of
% javaclasspath(), but they will still actually be on there, and classes
% from it will be picked up.
%
% Caveats:
% * This is a HACK and bound to be unsupported.
% * You need to call this before attempting to reference any class in it,
%   or Matlab may "remember" that the symbols could not be resolved.
% * There is no way to remove the new path entry once it is added.

parms = javaArray('java.lang.Class', 1);
parms(1) = java.lang.Class.forName('java.net.URL');
loaderClass = java.lang.Class.forName('java.net.URLClassLoader');
addUrlMeth = loaderClass.getDeclaredMethod('addURL', parms);
addUrlMeth.setAccessible(1);

sysClassLoader = java.lang.ClassLoader.getSystemClassLoader();

argArray = javaArray('java.lang.Object', 1);
for i = 1:length(file)
    jFile = java.io.File(file(i));
    argArray(1) = jFile.toURI().toURL();
    addUrlMeth.invoke(sysClassLoader, argArray);
end