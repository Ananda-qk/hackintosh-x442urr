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
            Method (_STA)
            {
                If (OSDW)
                {
                    Return (One)
                } Else
                {
                    Return (Zero)
                }
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
                    Return (Buffer () { 0x03 })
                }

                Return (Package (0x14)
                {
                    "hda-gfx",
                    "onboard-1",
                    
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
            Method (_STA)
            {
                If (OSDW)
                {
                    Return (One)
                } Else
                {
                    Return (Zero)
                }
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
        
        // import HDAS Obj, and turn it of
        External (HDAS, DeviceObj)
        Scope (HDAS)
        {
            Name (_STA, Zero)
        }
        
        // HDEF Audio Patch for ALC256 - layout 66
        Device (HDEF)
        {
            Name (_ADR, 0x001F0003)
            Method (_STA)
            {
                If (OSDW)
                {
                    Return (One)
                } Else
                {
                    Return (Zero)
                }
            }
            Method (_DSM, 4)
            {
                If ((Arg2 == Zero))
                {
                    Return (Buffer () { 0x03 })
                }
                
                Return (Package ()
                {
                    "layout-id",
                    Buffer ()
                    {
                        0x42, 0x00, 0x00, 0x00
                    },
                    "hda-gfx",
                    "onboard-1"
                })
            }
        }
        
        // import ETPD Obj, and patch custom CRS
        External (I2C1.ETPD, DeviceObj)
        Scope (I2C1.ETPD)
        {
            Method (_CRS)
            {
                Name (SBFX, ResourceTemplate ()
                {
                    I2cSerialBusV2 (0x0015, ControllerInitiated, 0x00061A80,
                        AddressingMode7Bit, "\\_SB.PCI0.I2C1",
                        0x00, ResourceConsumer, , Exclusive,
                        )
                })
                
                Name (SBFG, ResourceTemplate ()
                {
                    GpioInt (Level, ActiveLow, ExclusiveAndWake, PullDefault, 0x0000,
                        "\\_SB.PCI0.GPI0", 0x00, ResourceConsumer, ,
                        )
                        {   // Pin list
                            0x55
                        }
                })
                
                If (OSDW)
                {
                    Return (ConcatenateResTemplate (SBFX, SBFG))
                } Else
                {
                    // import original SBFI resource template
                    External (^XCRS.SBFI, UnknownObj)
                    Return (^XCRS.SBFI)
                }
            }
        }
    }
}