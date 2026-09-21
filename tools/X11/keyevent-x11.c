#include <X11/Xlib.h>
#include <X11/XKBlib.h>
#include <stdio.h>

int main(void)
{
    Display *display = XOpenDisplay(NULL);
    if (!display)
        return 1;

    unsigned int delay;
    unsigned int interval;

    Bool ok = XkbGetAutoRepeatRate(
        display,
        XkbUseCoreKbd,
        &delay,
        &interval
    );

    XCloseDisplay(display);

    if (!ok)
        return 1;

    printf(
        "{\"delay\":%u,\"interval\":%u}\n",
        delay,
        interval
    );

    return 0;
}