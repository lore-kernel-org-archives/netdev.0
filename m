From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH RFC 3/7] net: lan78xx: update for
 phy_(read|write)_mmd_indirect() removal
Date: Sun, 19 Mar 2017 18:00:36 +0100
Message-ID: <20170319170036.GA15440@lunn.ch>
References: <20170319105943.GR21222@n2100.armlinux.org.uk>
 <E1cpYZZ-0006Uj-8Z@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Woojung Huh <woojung.huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        Microchip Linux Driver Support <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <E1cpYZZ-0006Uj-8Z-eh5Bv4kxaXIk46pC+1QYvQNdhmdF6hFW@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 19, 2017 at 11:00:29AM +0000, Russell King wrote:
> lan78xx appears to use phylib in a rather weird way, accessing the PHY
> partly through phylib, and partly by makign direct accesses to it,

Hi Russell

s/makign/making

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
