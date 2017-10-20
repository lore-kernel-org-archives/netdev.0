From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] of_mdio: Fix broken PHY IRQ in case of probe
 deferral
Date: Fri, 20 Oct 2017 08:41:08 +0100 (WEST)
Message-ID: <20171020.084108.365516696070119583.davem@davemloft.net>
References: <1508327643-3579-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508327643-3579-1-git-send-email-geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Date: Wed, 18 Oct 2017 13:54:03 +0200

> The actual patch is unchanged since v1, sent on May 18.  Obviously I
> still cannot test it on a system with multiple PHYs, just like v1.
> 
> How can we proceed?

Andrew and Florian, please review this.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
