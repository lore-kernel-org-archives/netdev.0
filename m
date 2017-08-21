From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [RFC PATCH] dt-binding: net: sfp binding documentation
Date: Mon, 21 Aug 2017 16:05:30 +0200
Message-ID: <20170821140530.GD1703@lunn.ch>
References: <d73b635069a2054d110632f1f4196cd4bc281e7f.1503224886.git.baruch@tkos.co.il>
 <20170821125317.GS20805@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170821125317.GS20805-l+eeeJia6m9URfEZ8mYm6t73F7V6hmMc@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> The implementation that I've designed is based around the boards that
> I have access to and the various public SFP documentation.  I think
> documenting the bindings suggests that they are stable - I don't think
> we're really ready to make that assertion yet - there may be things
> that have been missed which will only come up when other people start
> using this code.

Hi Russell

That was the point of merging the code. It gets it into people hands
so they can start using it. I want to add support for DSA to make use
of phylink, since i have a couple of boards with SFF connected to
switch ports. I know Cumulus have interest in the code, for their
switches and so do Westermo. 

       Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
