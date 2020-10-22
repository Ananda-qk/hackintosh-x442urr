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
    External (\_SB.PCI0, DeviceObj)
    Scope (\_SB.PCI0)
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
        
        // import external obj, and turn off GFX0 device state
        External (GFX0, DeviceObj)
        Scope (GFX0)
        {
            If (OSDW)
            {
                Name (_STA, Zero)
            }
        }
        
        // IGPU Framebuffer patch for Intel UHD 620
        Device (IGPU)
        {
            Name (_ADR, 0x00020000)  // _ADR: Address
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (OSDW ())
                {
                    Return (One)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If ((Arg2 == Zero))
                {
                    Return (Buffer (One)
                    {
                         0x03                                             // .
                    })
                }

                Return (Package (0x14)
                {
                    "hda-gfx", 
                    Buffer (0x0A)
                    {
                        "onboard-1"
                    }, 

                    "disable-agdc", 
                    Buffer (0x04)
                    {
                         0x01, 0x00, 0x00, 0x00                           // ....
                    }, 

                    "force-online", 
                    Buffer (0x04)
                    {
                         0x01, 0x00, 0x00, 0x00                           // ....
                    }, 

                    "device-id", 
                    Buffer (0x04)
                    {
                         0x16, 0x59, 0x00, 0x00                           // .Y..
                    }, 

                    "AAPL,ig-platform-id", 
                    Buffer (0x04)
                    {
                         0x00, 0x00, 0x16, 0x59                           // ...Y
                    }, 

                    "framebuffer-con1-enable", 
                    Buffer (0x04)
                    {
                         0x01, 0x00, 0x00, 0x00                           // ....
                    }, 

                    "framebuffer-con1-type", 
                    Buffer (0x04)
                    {
                         0x00, 0x08, 0x00, 0x00                           // ....
                    }, 

                    "framebuffer-con2-enable", 
                    Buffer (0x04)
                    {
                         0x01, 0x00, 0x00, 0x00                           // ....
                    }, 

                    "framebuffer-con2-type", 
                    Buffer (0x04)
                    {
                         0x00, 0x08, 0x00, 0x00                           // ....
                    }, 

                    "framebuffer-patch-enable", 
                    Buffer (0x04)
                    {
                         0x01, 0x00, 0x00, 0x00                           // ....
                    }
                })
            }
            
            Device (^^PNLF)
            {
                Name (_ADR, Zero)
                Name (_HID, EisaId ("APP0002"))
                Name (_CID, "backlight")
                Name (_UID, 0x10)
                Method (_STA)
                {
                    If (OSDW)
                    {
                        Return (0x0B)
                    } Else
                    {
                        Return (Zero)
                    }
                }
            }
        }
        
        // import Optimus _OFF method to disable Nvidia GPU
        External (RP01.PEGP._OFF, MethodObj)
        Device (DGPU)
        {
            Name (_HID, "DGPU0000")
            If (!OSDW)
            {
                Name (_STA, Zero)
            }
            
            Method (_INI)
            {
                If (CondRefOf (\_SB.PCI0.RP01.PEGP._OFF))
                {
                    If (OSDW)
                    {
                        \_SB.PCI0.RP01.PEGP._OFF ()
                    }
                }
            }
        }
    }
}