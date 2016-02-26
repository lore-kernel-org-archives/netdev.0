From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 03/12] net-next: mediatek: add embedded switch
 driver (ESW)
Date: Fri, 26 Feb 2016 12:44:59 -0500 (EST)
Message-ID: <20160226.124459.2214228338245540067.davem@davemloft.net>
References: <20160226151813.GD12022@lunn.ch>
	<56D06E3F.1020100@openwrt.org>
	<20160226170545.GE12022@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: blogic@openwrt.org, Fred.Chang@mediatek.com,
	steven.liu@mediatek.com, netdev@vger.kernel.org,
	Carlos.Huang@mediatek.com, linux-kernel@vger.kernel.org,
	linux-mediatek@lists.infradead.org, matthias.bgg@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160226170545.GE12022@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 26 Feb 2016 18:05:45 +0100

> I think it is great a vendor is providing funding to get code
> upstream. However, that code needs to conform with current kernel
> architecture and design philosophy.
> 
> We as a community also need to be consistent. We have recently push
> back on Microchip with there LAN9352 who want to do something very
> similar, introduce the MAC and a very dumb switch driver. They are now
> looking at what it means to do a DSA driver. There is also talk of
> writing a DSA driver for the ks8995 family.
> 
> As David said recently, a year ago this probably would of been
> accepted. But now, switches need to be DSA or switchdev.

+1
