DefinitionBlock ("", "SSDT", 2, "HAMCUK", "Hack", 0)
{
    
    Scope (\)
    {
        Method (OSDW)
        {
            If (_OSI ("Darwin"))
            {
                Return (One)
            } Else
            {
                Return (Zero)
            }
        }
    }
    
    // Import PCI0 Object
    External (_SB.PCI0, DeviceObj)
    Scope (_SB.PCI0)
    {
        // import LPCB obj and creating fake ec
        External (LPCB, DeviceObj)
        Device (LPCB.EC)
        {
            Name (_HID, "HAMC0000")
            If (!OSDW)
            {
                Name (_STA, Zero)
            }
        }
    }
}