From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v0 09/10] net: phy: Re-attempt custom DT configuration
 after configuration
Date: Sat, 16 Jul 2016 18:44:54 +0200
Message-ID: <20160716164454.GK1777@lunn.ch>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
 <1468679348-10522-10-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Imre Kaloz <kaloz-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1468679348-10522-10-git-send-email-jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 16, 2016 at 03:29:07PM +0100, Jamie Lentin wrote:
> marvell,reg-init is generally used to apply a custom LED configuration
> on boot. However this is then blatted in m88e1121_config_aneg when the
> interface is brought up. Re-apply any custom configuration afterwards,
> to keep custom LED configuration.

This has been fixed in net-next.

     Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
