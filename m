From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Tue, 26 Apr 2016 12:26:24 -0400 (EDT)
Message-ID: <20160426.122624.967268334782802268.davem@davemloft.net>
References: <20160425205650.GA31129@lunn.ch>
	<666dffb41a922b0c8638f2f002a2de08@mail.gmail.com>
	<20160426121335.GC11668@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
	suzuki.poulose-5wv7dgnIgG8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	punit.agrawal-5wv7dgnIgG8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, anup.patel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: andrew-g2DYL2Zd6BY@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160426121335.GC11668-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Date: Tue, 26 Apr 2016 14:13:35 +0200

> On Tue, Apr 26, 2016 at 02:03:27PM +0530, Pramod Kumar wrote:
>> As you can see from above points, trying to re-use Linux Ethernet MDIO mux
>> framework for non-Ethernet PHYs is not the right way.
> 
> And as i pointed out, all your arguments are wrong, bar one. And i
> doubt that one argument is sufficient to duplicate a lot of code which
> already exists and does 95% of what you need.

+1
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
