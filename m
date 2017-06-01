From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 4/5] net: phy: add XAUI and 10GBASE-KR PHY connection
 types
Date: Thu, 1 Jun 2017 14:30:06 +0200
Message-ID: <20170601123006.GD9282@lunn.ch>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJX-00043v-3M@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <E1dGNJX-00043v-3M-eh5Bv4kxaXIk46pC+1QYvQNdhmdF6hFW@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 01, 2017 at 11:26:47AM +0100, Russell King wrote:
> XAUI allows XGMII to reach an extended distance by using a XGXS layer at
> each end of the MAC to PHY link, operating over four Serdes lanes.
> 
> 10GBASE-KR is a single lane Serdes backplane ethernet connection method
> with autonegotiation on the link.  Some PHYs use this to connect to the
> ethernet interface at 10G speeds, switching to other connection types
> when utilising slower speeds.
> 
> 10GBASE-KR is also used for XFI and SFI to connect to XFP and SFP fiber
> modules.
> 
> Signed-off-by: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>

Reviewed-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
