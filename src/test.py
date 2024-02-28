import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from cocotb.binary import BinaryValue


@cocotb.test()
async def test_4bit_cpu(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # reset
    dut._log.info("reset")
    dut.ena.value = 1
    dut.rst_n.value = 0
    dut.ui_in.value = BinaryValue('00000000')
    dut.uio_in.value = BinaryValue('00000000')
    dut.uio_oe.value = BinaryValue('00000000')
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    #Testfall 1: Einen Wert in Speicher schreiben
    dut._log.info("Testfall 1: Einen Wert in Speicher schreiben 0101")
    dut._log.info("Erwartetes Ergebnis: Akkumulatorwert sollte 00000101 sein.")
    
    #Schreibe Wert in Speicher (Adresse 3)
    dut.ui_in.value = BinaryValue('01010011') #Adresse 3, Wert 0101
    dut.uio_in.value = BinaryValue('00100001') #Opcode WRITE
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    
    #Überprüfe Speicherinhalt Adresse 3
    dut.ui_in.value = BinaryValue('00000011') #Adresse 3 lesen
    dut.uio_in.value = BinaryValue('00110000') #Opcpde LOAD
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    
    if (dut.ou_out.value != 00000101):
        dut._log.info("Tatsächliches Ergebnis: {} Testfall 1 fehlgeschlagen!".format(dut-ou_out.value))
    else:
        dut._log.info("Tatsächliches Ergebnis: {} Testfall 1 erfolgreich!".format(dut-ou_out.value))
    
    #Testfall 2: Addition von zwei Werten
    dut._log.info("Testfall 2: Gespeicherten Wert von Testfall 1 mit zweiten Wert addieren")
    dut._log.info("Erwartetes Ergebnis: Akkumulatorwert sollte 0101 + 0011 = 1000")
    dut.ui_in.value = BinaryValue('00000011') #Wert aus Adresse 3 in Akkumulator laden
    dut.uio_in.value = BinaryValue('00110000') #Opcode LOAD
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    
    dut.ui_in.value = BinaryValue('00110000')
    dut.uio_in.value = BinaryValue('00000000')
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    
    if (dut.ou_out.value != 00001000):
        dut._log.info("Tatsächliches Ergebnis: {} Testfall 1 fehlgeschlagen!".format(dut-ou_out.value))
    else:
        dut._log.info("Tatsächliches Ergebnis: {} Testfall 1 erfolgreich!".format(dut-ou_out.value))
    
    #Testfall 3: NOT Funktion
    dut._log.info("Testfall 2: Gespeicherten Wert von Testfall 1 negieren")
    dut._log.info("Erwartetes Ergebnis: Akkumulatorwert sollte 1010 sein")
    dut.ui_in.value = BinaryValue('00000011') #Wert aus Adresse 3 in Akkumulator laden
    dut.uio_in.value = BinaryValue('00110000') #Opcode LOAD
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    
    dut.ui_in.value = BinaryValue('00110000')
    dut.uio_in.value = BinaryValue('10000000')
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    
    if (dut.ou_out.value != 00001010):
        dut._log.info("Tatsächliches Ergebnis: {} Testfall 1 fehlgeschlagen!".format(dut-ou_out.value))
    else:
        dut._log.info("Tatsächliches Ergebnis: {} Testfall 1 erfolgreich!".format(dut-ou_out.value))
