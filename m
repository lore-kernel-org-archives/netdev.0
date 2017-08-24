From: Stefan Chulski <stefanc@marvell.com>
Subject: RE: [PATCH net-next 02/13] phy: add the mvebu cp110 comphy driver
Date: Thu, 24 Aug 2017 13:57:04 +0000
Message-ID: <e83030e8499843e8af9004c2562380dc@IL-EXCH01.marvell.com>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-3-antoine.tenart@free-electrons.com>
 <20170824133922.GC8022@lunn.ch> <20170824134444.GA28443@kwain>
 <20170824135127.GE8022@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "kishon@ti.com" <kishon@ti.com>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mw@semihalf.com" <mw@semihalf.com>,
        "miquel.raynal@free-electrons.com" <miquel.raynal@free-electrons.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824135127.GE8022@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Thursday, August 24, 2017 4:51 PM
> To: Antoine Tenart <antoine.tenart@free-electrons.com>
> Cc: davem@davemloft.net; kishon@ti.com; jason@lakedaemon.net;
> sebastian.hesselbarth@gmail.com; gregory.clement@free-electrons.com;
> thomas.petazzoni@free-electrons.com; Nadav Haklai <nadavh@marvell.com>;
> linux@armlinux.org.uk; linux-kernel@vger.kernel.org; mw@semihalf.com;
> Stefan Chulski <stefanc@marvell.com>; miquel.raynal@free-electrons.com;
> netdev@vger.kernel.org
> Subject: Re: [PATCH net-next 02/13] phy: add the mvebu cp110 comphy driver
> 
> Hi Antione.
> 
> > How would you name it if not "comphy-cp110"?
> 
> Good question...
> 
> '7000-cpmphy-cp110'
> '8000-cpmphy-cp110'
> 
> ??
> 
> 	Andrew

A8K Marvell SoC has two South Bridge communication controllers
and A7K only one communication controllers, but its identical
communication controllers 110. Next generation will has another number 1xx.

Stefan,
Regards.
