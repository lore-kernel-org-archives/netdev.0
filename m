From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 net-next 3/5] dsa: add DSA switch driver for Microchip
 KSZ9477
Date: Wed, 31 May 2017 22:23:49 +0200
Message-ID: <20170531202349.GG11230@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40AA5578@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, f.fainelli@gmail.com,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60213 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751096AbdEaUXx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 16:23:53 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40AA5578@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 08:19:19PM +0000, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <Woojung.Huh@microchip.com>
> 
> The KSZ9477 is a fully integrated layer 2, managed, 7 ports GigE switch
> with numerous advanced features. 5 ports incorporate 10/100/1000 Mbps PHYs.
> The other 2 ports have interfaces that can be configured as SGMII, RGMII, MII
> or RMII. Either of these may connect directly to a host processor or
> to an external PHY. The SGMII port may interface to a fiber optic transceiver.
> 
> This driver currently supports vlan, fdb, mdb & mirror dsa switch operations.
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
