From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/9] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Wed, 14 Jun 2017 03:10:22 +0200
Message-ID: <20170614011022.GE23384@lunn.ch>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-7-salil.mehta@huawei.com>
 <ba416774-9ccc-e6b6-3518-fb492b8b2858@gmail.com>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B7A2554@FRAEML521-MBX.china.huawei.com>
 <20170613224042.GF15847@lunn.ch>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B7A26E1@FRAEML521-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F93B7A26E1@FRAEML521-MBX.china.huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Since I would be touching the core, lots of drivers will get impacted and will
> have to wait till everyone gives clean signal. This will impact our internal
> deadlines. But as I said I am eager to cooperate & contribute :)

Just as an FYI.

Your internal deadlines are irrelevant. We will reject your patches
until we are happy with it. We probably won't accept a hack around a
core feature limitation. We will want you to fix the core limitation
and then do it right in the driver.

    Andrew
