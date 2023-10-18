#include <NextagEmbeddedPlatform/drivers/digital_io.h>
#include <avr/delay.h>

int main()
{
    NextagEmbeddedPlatform::Drivers::DigitalIO led(NextagEmbeddedPlatform::Drivers::Pins::B5);

    led.setPinMode(NextagEmbeddedPlatform::Drivers::Mode::OUTPUT);

    for(;;)
    {
        led.setState(NextagEmbeddedPlatform::Drivers::State::HIGH);
        _delay_ms(1000);
        led.setState(NextagEmbeddedPlatform::Drivers::State::LOW);
        _delay_ms(1000);
    }
}