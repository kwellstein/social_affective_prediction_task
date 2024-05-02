rem **** Build sequence for libptbdrawtext_ftgl64.dll, our 64-Bit text renderer plugin for Windows ****
rem **** Requires 64-Bit GStreamer 1.22.0+ MSVC SDK and MSVC 2019 Community edition installed.     ****

rem **** Set pathes to the MSVC 2019 Community edition build tools and included Windows 10 SDK ****
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"

rem Disabled the following, not needed right now for GStreamer 1.22, was needed for GStreamer 1.20
rem dumpbin.exe /OUT:fontconfig-1.functions /EXPORTS C:/gstreamer/1.0/msvc_x86_64/bin/fontconfig-1.dll
rem lib /def:fontconfig-1.def /machine:x64 /out:fontconfig.lib

cl /c /GR /W3 /EHs /D_CRT_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_DEPRECATE /D_SECURE_SCL=0 /nologo /MD /I"C:\gstreamer\1.0\msvc_x86_64\include\freetype2" /I"C:\gstreamer\1.0\msvc_x86_64\include" /Foqstringqcharemulation.obj /O2 /Oy- /DNDEBUG -DOGLFT_BUILD qstringqcharemulation.cpp
cl /c /GR /W3 /EHs /D_CRT_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_DEPRECATE /D_SECURE_SCL=0 /nologo /MD /I"C:\gstreamer\1.0\msvc_x86_64\include\freetype2" /I"C:\gstreamer\1.0\msvc_x86_64\include" /Folibptbdrawtext_ftgl.obj /O2 /Oy- /DNDEBUG -DOGLFT_BUILD libptbdrawtext_ftgl.cpp
cl /c /GR /W3 /EHs /D_CRT_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_DEPRECATE /D_SECURE_SCL=0 /nologo /MD /I"C:\gstreamer\1.0\msvc_x86_64\include\freetype2" /I"C:\gstreamer\1.0\msvc_x86_64\include" /FoOGLFT.obj /O2 /Oy- /DNDEBUG -DOGLFT_BUILD OGLFT.cpp
link /out:".\libptbdrawtext_ftgl64.dll" /dll /LIBPATH:"C:\gstreamer\1.0\msvc_x86_64\lib" fontconfig.lib freetype.lib opengl32.lib glu32.lib /MACHINE:X64 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib qstringqcharemulation.obj libptbdrawtext_ftgl.obj OGLFT.obj /nologo /manifest /incremental:NO
del *.obj
del libptbdrawtext_ftgl64.lib
del libptbdrawtext_ftgl64.exp
del libptbdrawtext_ftgl64.dll.manifest
