#pragma comment(lib, "user32.lib")
#include <windows.h>
#include <iostream>

int main()
{
    UINT delay = 0;
    UINT speed = 0;

    if (!SystemParametersInfoW(
            SPI_GETKEYBOARDDELAY,
            0,
            &delay,
            0))
        return 1;

    if (!SystemParametersInfoW(
            SPI_GETKEYBOARDSPEED,
            0,
            &speed,
            0))
        return 1;

    // const int delay_ms = 250 * (delay + 1);
    const int delay_ms = static_cast<int>(250 * (delay + 1) * 0.93 + 0.5);

    const double repeats_per_sec =
        2.5 + 27.5 * speed / 31.0;

    const int interval_ms =
        static_cast<int>(1000.0 / repeats_per_sec + 0.5);

    std::cout
        << "{\"delay\":" << delay_ms
        << ",\"interval\":" << interval_ms
        << "}\n";

    return 0;
}
