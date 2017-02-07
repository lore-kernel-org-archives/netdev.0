From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/4] net: dsa: Support for pdata in dsa2
Date: Tue, 07 Feb 2017 10:52:11 -0500 (EST)
Message-ID: <20170207.105211.821604338637993231.davem@davemloft.net>
References: <20170204205715.14708-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, linux@armlinux.org.uk,
        vivien.didelot@savoirfairelinux.com,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170204205715.14708-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat,  4 Feb 2017 12:57:07 -0800

> This is not exactly new, and was sent before, although back then, I did not
> have an user of the pre-declared MDIO board information, but now we do. Note
> that I have additional changes queued up to have b53 register platform data for
> MIPS bcm47xx and bcm63xx.
> 
> Yes I know that we should have the Orion platforms eventually be converted to
> Device Tree, but until that happens, I don't want any remaining users of the
> old "dsa" platform device (hence the previous DTS submissions for ARM/mvebu)
> and, there will be platforms out there that most likely won't never see DT
> coming their way (BCM47xx is almost 100% sure, BCM63xx maybe not in a distant
> future).
> 
> We would probably want the whole series to be merged via David Miller's tree
> to simplify things.

Series applied, thanks Florian.
