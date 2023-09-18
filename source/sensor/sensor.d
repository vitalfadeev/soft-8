module sensor.sensor;

import types;


interface ISensor
{
    void sense( D d );
}


abstract
class SensorClass
{
    void sense( D d ) {};
}
