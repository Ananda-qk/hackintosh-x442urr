DefinitionBlock ("", "SSDT", 2, "HAMCUK", "Hack", 0)
{
    
    Scope (\)
    {
        // method osdw to check the booted kernel
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
    
    // import Processor obj to inject plugin type
    External (\_PR.PR00, ProcessorObj)
    Scope (\_PR.PR00)
    {
        Method (_DSM, 4)
        {
            If ((Arg2 == Zero))
            {
                Return (Buffer () { 0x03 })
            }
            
            If (OSDW)
            {
                Return (Package ()
                {
                    "plugin-type",
                    One
                })
            }
        }
    }
    
    Scope (\_SB)
    {
        
        // USBX Patch
        Device (USBX)
        {
            Name (_ADR, Zero)
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
                    "kUSBSleepPowerSupply",
                    0x13EC,
                    "kUSBSleepPortCurrentLimit",
                    0x0834,
                    "kUSBWakePowerSupply",
                    0x13EC,
                    "kUSBWakePortCurrentLimit",
                    0x0834
                })
            }
        }
        
        // PNLF for Kabylake
        Device (PNLF)
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
    
    // MAIN PATCH GOES HERE
    
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

                Return (Package ()
                {
                    "name",
                    "display",
                    
                    "AAPL,slot-name",
                    "Built-in",
                    
                    "device_type",
                    "Display Controller",
                    
                    "model",
                    "Intel UHD 620 Graphics",
                    
                    "hda-gfx",
                    "onboard-1",
                    
                    "disable-agdc", 
                    Buffer ()
                    {
                         0x01, 0x00, 0x00, 0x00                           // ....
                    }, 

                    "force-online", 
                    Buffer ()
                    {
                         0x01, 0x00, 0x00, 0x00                           // ....
                    }, 

                    "device-id", 
                    Buffer ()
                    {
                         0x16, 0x59, 0x00, 0x00                           // .Y..
                    }, 

                    "AAPL,ig-platform-id", 
                    Buffer ()
                    {
                         0x00, 0x00, 0x16, 0x59                           // ...Y
                    }, 

                    "framebuffer-con1-enable", 
                    Buffer ()
                    {
                         0x01, 0x00, 0x00, 0x00                           // ....
                    }, 

                    "framebuffer-con1-type", 
                    Buffer ()
                    {
                         0x00, 0x08, 0x00, 0x00                           // ....
                    }, 

                    "framebuffer-con2-enable", 
                    Buffer ()
                    {
                         0x01, 0x00, 0x00, 0x00                           // ....
                    }, 

                    "framebuffer-con2-type", 
                    Buffer ()
                    {
                         0x00, 0x08, 0x00, 0x00                           // ....
                    }, 

                    "framebuffer-patch-enable", 
                    Buffer ()
                    {
                         0x01, 0x00, 0x00, 0x00                           // ....
                    }
                })
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
                    "name",
                    "HDEF",
                    
                    "AAPL,slot-name",
                    "Built-in",
                    
                    "device_type",
                    "Audio Controller",
                    
                    "model",
                    "Hamcuks Realtek HD Audio ALC256",
                    
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
                    External (^XCRS, MethodObj)
                    ^XCRS ()
                }
            }
        }
    }

    // END MAIN PATCH

    // MISC PATCH GOES HERE
    Scope (\_SB.PCI0)
    {
        Device (MCHC)
        {
            Name (_ADR, Zero)
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
        
        // import RP05 object
        External (RP05, DeviceObj)
        Scope (RP05)
        {
            // import PXSX and turn it off
            External (PXSX, DeviceObj)
            Scope (PXSX)
            {
                If (OSDW)
                {
                    Name (_STA, Zero)
                }
            }
            
            // import GLAN and turn it off
            External (GLAN, DeviceObj)
            Scope (GLAN)
            {
                If (OSDW)
                {
                    Name (_STA, Zero)
                }
            }
            
            Device (GIGE)
            {
                Name (_ADR, Zero)
                If (!OSDW)
                {
                    Name (_STA, Zero)
                }
                Method (_DSM, 4)
                {
                    If ((Arg2 == Zero))
                    {
                        Return (Buffer () { 0x03 })
                    }
                    
                    Return (Package () {
                        "name",
                        "GIGE",
                        "AAPL,slot-name",
                        "Built-in",
                        "device_type",
                        "Ethernet Controller"
                    })
                }
            }
        }
        
        // import RP06 object
        External (RP06, DeviceObj)
        Scope (RP06)
        {
            // import PXSX and turn it off
            External (PXSX, DeviceObj)
            Scope (PXSX)
            {
                If (OSDW)
                {
                    Name (_STA, Zero)
                }
            }
            
            Device (ARPT)
            {
                Name (_ADR, Zero)
                If (!OSDW)
                {
                    Name (_STA, Zero)
                }
                Method (_DSM, 4)
                {
                    If ((Arg2 == Zero))
                    {
                        Return (Buffer () { 0x03 })
                    }
                    
                    Return (Package () {
                        "name",
                        "ARPT",
                        "AAPL,slot-name",
                        "Built-in",
                        "device_type",
                        "Aiport Extreme",
                        "model",
                        "Hamcuks Intel Wi-Fi 6 AX200"
                    })
                }
            }
        }
    }
    // END MISC PATCH
}