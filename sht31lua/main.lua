PROJECT = "i2c"
VERSION = "1.0.0"

sys = require("sys")

-- SHT31-DIS 7位地址
i2cSlaveAddr = 0x44
--硬件i2c ID
i2cId = 0

function getSHT31DISData()
    -- 发送测量命令
    i2c.send(i2cId, i2cSlaveAddr, string.char(0x2c, 0x06))
    -- 等待测量完成
    sys.wait(50)

    -- 读取温湿度数据
    receivedData = i2c.recv(i2cId, i2cSlaveAddr, 6)
    -- 分离温度数据
    local tempBit = string.byte(receivedData, 1) * 256 + string.byte(receivedData, 2)
    -- 分离湿度数据
    local humidityBit = string.byte(receivedData, 4) * 256 + string.byte(receivedData, 5)
    -- 转换温湿度结果
    local calcTemp = -45 + 175 * (tempBit / 65535) --计算温度，详见官网文档
    local calcHum = 100 * (humidityBit / 65535) --计算湿度，详见官网文档
    log.info(PROJECT .. ".当前温度", string.format("%.2f℃", calcTemp))
    log.info(PROJECT .. ".当前湿度", string.format("%.2f%%", calcHum))

end

sys.taskInit(function()
    -- 初始化i2c
    local setupRes = i2c.setup(i2cId, i2c.FAST)
    log.info(PROJECT .. ".setup", setupRes)
    if setupRes ~= i2c.FAST then
        log.error(PROJECT .. ".setup", "ERROR")
        i2c.close(i2cId)
        return
    end
    while true do
        getSHT31DISData()
        sys.wait(5000)
    end
end)

sys.run()
