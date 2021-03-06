/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module derelict.opengl.glx;

version (freebsd)
{
    version = GLX;
}

else version (FreeBSD)
{
    version = GLX;
}

else version (linux)
{
    version = GLX;
}

version(GLX)
{

private
{
    import derelict.opengl.gltypes;
    import derelict.util.compat;
    import derelict.util.loader;
    import derelict.util.xtypes;
}

struct __GLXcontextRec {}
struct __GLXFBConfigRec {}

typedef uint GLXContentID;
typedef uint GLXPixmap;
typedef uint GLXDrawable;
typedef uint GLXPbuffer;
typedef uint GLXWindow;
typedef uint GLXFBConfigID;

typedef __GLXcontextRec *GLXContext;      // __GLXcontextRec type is opaque
typedef __GLXFBConfigRec *GLXFBConfig;    // __GLXFBConfigRec type is opaque

/*
 * GLX Events
 */

struct GLXPbufferClobberEvent
{
    int         event_type;
    int         draw_type;
    uint        serial;
    Bool        send_event;
    Display*    display;
    GLXDrawable drawable;
    uint        buffer_mask;
    uint        aux_buffer;
    int         x, y;
    int         width, height;
    int         count;
}

union GLXEvent
{
    GLXPbufferClobberEvent glxpbufferclobber;
    int pad[24];
}

// Function pointer variables

extern (C)
{
     mixin(gsharedString!() ~
     "
     XVisualInfo* function(Display*,int,int*) glXChooseVisual;
     void function(Display*,GLXContext,GLXContext,uint) glXCopyContext;
     GLXContext function(Display*,XVisualInfo*,GLXContext,Bool) glXCreateContext;
     GLXPixmap function(Display*,XVisualInfo*,Pixmap) glXCreateGLXPixmap;
     void function(Display*,GLXContext) glXDestroyContext;
     void function(Display*,GLXPixmap) glXDestroyGLXPixmap;
     int  function(Display*,XVisualInfo*,int,int*) glXGetConfig;
     GLXContext function() glXGetCurrentContext;
     GLXDrawable function() glXGetCurrentDrawable;
     Bool function(Display*,GLXContext) glXIsDirect;
     Bool function(Display*,GLXDrawable,GLXContext) glXMakeCurrent;
     Bool function(Display*,int*,int*) glXQueryExtension;
     Bool function(Display*,int*,int*) glXQueryVersion;
     void function(Display*,GLXDrawable) glXSwapBuffers;
     void function(Font,int,int,int) glXUseXFont;
     void function() glXWaitGL;
     void function() glXWaitX;
     char* function(Display*,int) glXGetClientString;
     char* function(Display*,int,int) glXQueryServerString;
     char* function(Display*,int) glXQueryExtensionsString;

    /* GLX 1.3 */

     GLXFBConfig* function(Display*,int,int*) glXGetFBConfigs;
     GLXFBConfig* function(Display*,int,int*,int*) glXChooseFBConfig;
     int  function(Display*,GLXFBConfig,int,int*) glXGetFBConfigAttrib;
     XVisualInfo* function(Display*,GLXFBConfig) glXGetVisualFromFBConfig;
     GLXWindow function(Display*,GLXFBConfig,Window,int*) glXCreateWindow;
     void function(Display*,GLXWindow) glXDestroyWindow;
     GLXPixmap function(Display*,GLXFBConfig,Pixmap,int*) glXCreatePixmap;
     void function(Display*,GLXPixmap) glXDestroyPixmap;
     GLXPbuffer function(Display*,GLXFBConfig,int*) glXCreatePbuffer;
     void function(Display*,GLXPbuffer) glXDestroyPbuffer;
     void function(Display*,GLXDrawable,int,uint*) glXQueryDrawable;
     GLXContext function(Display*,GLXFBConfig,int,GLXContext,Bool) glXCreateNewContext;
     Bool function(Display*,GLXDrawable,GLXDrawable,GLXContext) glXMakeContextCurrent;
     GLXDrawable function() glXGetCurrentReadDrawable;
     Display* function() glXGetCurrentDisplay;
     int  function(Display*,GLXContext,int,int*) glXQueryContext;
     void function(Display*,GLXDrawable,uint) glXSelectEvent;
     void function(Display*,GLXDrawable,uint*) glXGetSelectedEvent;

    /* GLX 1.4+ */
     void* function(CCPTR) glXGetProcAddress;
     ");
}

/* GLX extensions -- legacy */

/*
GLXContextID            function(const GLXContext)
                            pfglXGetContextIDEXT;
GLXContext              function(Display*,GLXContextID)
                            pfglXImportContextEXT;
void                    function(Display*,GLXContext)
                            pfglXFreeContextEXT;
int                     function(Display*,GLXContext,int,int*)
                            pfglXQueryContextInfoEXT;
Display*                function()
                            pfglXGetCurrentDisplayEXT;
void function()         function(const GLubyte*)
                            pfglXGetProcAddressARB;
*/

/+

// All extensions are disabled in the current version
// until further testing is done and need is established.

void*                   function(GLsizei,GLfloat,GLfloat,GLfloat)
                            glXAllocateMemoryNV;
void                    function(GLvoid*)
                            glXFreeMemoryNV;
void*                   function(GLsizei,GLfloat,GLfloat,GLfloat)
                            PFNGLXALLOCATEMEMORYNVPROC;
void                    function(GLvoid*)
                            PFNGLXFREEMEMORYNVPROC;

/* Mesa specific? */

// work in progress

/* GLX_ARB specific? */

Bool                    function(Display*, GLXPbuffer,int)
                            glXBindTexImageARB;
Bool                    function(Display*, GLXPbuffer,int)
                            glXReleaseTexImageARB;
Bool                    function(Display*,GLXDrawable,int*)
                            glXDrawableAttribARB;

+/

package
{
    void loadPlatformGL(void delegate(void**, string, bool doThrow = true) bindFunc)
    {
        bindFunc(cast(void**)&glXChooseVisual, "glXChooseVisual");
        bindFunc(cast(void**)&glXCopyContext, "glXCopyContext");
        bindFunc(cast(void**)&glXCreateContext, "glXCreateContext");
        bindFunc(cast(void**)&glXCreateGLXPixmap, "glXCreateGLXPixmap");
        bindFunc(cast(void**)&glXDestroyContext, "glXDestroyContext");
        bindFunc(cast(void**)&glXDestroyGLXPixmap, "glXDestroyGLXPixmap");
        bindFunc(cast(void**)&glXGetConfig, "glXGetConfig");
        bindFunc(cast(void**)&glXGetCurrentContext, "glXGetCurrentContext");
        bindFunc(cast(void**)&glXGetCurrentDrawable, "glXGetCurrentDrawable");
        bindFunc(cast(void**)&glXIsDirect, "glXIsDirect");
        bindFunc(cast(void**)&glXMakeCurrent, "glXMakeCurrent");
        bindFunc(cast(void**)&glXQueryExtension, "glXQueryExtension");
        bindFunc(cast(void**)&glXQueryVersion, "glXQueryVersion");
        bindFunc(cast(void**)&glXSwapBuffers, "glXSwapBuffers");
        bindFunc(cast(void**)&glXUseXFont, "glXUseXFont");
        bindFunc(cast(void**)&glXWaitGL, "glXWaitGL");
        bindFunc(cast(void**)&glXWaitX, "glXWaitX");
        bindFunc(cast(void**)&glXGetClientString, "glXGetClientString");
        bindFunc(cast(void**)&glXQueryServerString, "glXQueryServerString");
        bindFunc(cast(void**)&glXQueryExtensionsString, "glXQueryExtensionsString");

        bindFunc(cast(void**)&glXGetFBConfigs, "glXGetFBConfigs");
        bindFunc(cast(void**)&glXChooseFBConfig, "glXChooseFBConfig");
        bindFunc(cast(void**)&glXGetFBConfigAttrib, "glXGetFBConfigAttrib");
        bindFunc(cast(void**)&glXGetVisualFromFBConfig, "glXGetVisualFromFBConfig");
        bindFunc(cast(void**)&glXCreateWindow, "glXCreateWindow");
        bindFunc(cast(void**)&glXDestroyWindow, "glXDestroyWindow");
        bindFunc(cast(void**)&glXCreatePixmap, "glXCreatePixmap");
        bindFunc(cast(void**)&glXDestroyPixmap, "glXDestroyPixmap");
        bindFunc(cast(void**)&glXCreatePbuffer, "glXCreatePbuffer");
        bindFunc(cast(void**)&glXDestroyPbuffer, "glXDestroyPbuffer");
        bindFunc(cast(void**)&glXQueryDrawable, "glXQueryDrawable");
        bindFunc(cast(void**)&glXCreateNewContext, "glXCreateNewContext");
        bindFunc(cast(void**)&glXMakeContextCurrent, "glXMakeContextCurrent");
        bindFunc(cast(void**)&glXGetCurrentReadDrawable, "glXGetCurrentReadDrawable");
        bindFunc(cast(void**)&glXGetCurrentDisplay, "glXGetCurrentDisplay");
        bindFunc(cast(void**)&glXQueryContext, "glXQueryContext");
        bindFunc(cast(void**)&glXSelectEvent, "glXSelectEvent");
        bindFunc(cast(void**)&glXGetSelectedEvent, "glXGetSelectedEvent");

        bindFunc(cast(void**)&glXGetProcAddress, "glXGetProcAddressARB");
    }

    void* loadGLSymbol(string symName)
    {
        return glXGetProcAddress(toCString(symName));
    }
}

}   // version(linux)
