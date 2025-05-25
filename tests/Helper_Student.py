def ToHex(value):
    try:
        ret = hex(value.integer)
    except: #If there are 'x's in the value
        ret = "0b" + str(value)
    return ret

#Populate the below functions as in the example lines of code to print your values for debugging
def Log_Datapath(dut,logger):
    #Log whatever signal you want from the datapath, called before positive clock edge
    logger.debug("************ DUT DATAPATH Signals ***************")
    #dut._log.info("RegWrite:%s", ToHex(dut.my_datapath.RegWrite.value))
    #dut._log.info("SrcA:%s", ToHex(dut.my_datapath.SrcA.value))
    #dut._log.info("SrcB:%s", ToHex(dut.my_datapath.SrcB.value))
    #dut._log.info("ALUControl:%s", ToHex(dut.my_datapath.ALUControl.value))
    #dut._log.info("ALUResult:%s", ToHex(dut.my_datapath.ALUResult.value))
    #dut._log.info("WD3:%s", ToHex(dut.my_datapath.WD3.value))
    #dut._log.info("WriteData:%s", ToHex(dut.my_datapath.WriteData.value))
    #dut._log.info("ReadData:%s", ToHex(dut.my_datapath.ReadData.value))


def Log_Controller(dut,logger):
    #Log whatever signal you want from the controller, called before positive clock edge
    logger.debug("************ DUT Controller Signals ***************")

    