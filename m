From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v3 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Mon, 26 Sep 2016 17:12:41 +0200
Message-ID: <20160926151241.GA10516@lunn.ch>
References: <1474897705-30802-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org
To: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1474897705-30802-1-git-send-email-Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 26, 2016 at 07:18:25PM +0530, Raju Lakkaraju wrote:
> Hi,
> 
> Thank you for review the code and valuable comments.
> Summary of changes:
>         V1: Initial version of Edge-rate driver add by using IOCTL.
>         V2: Changed edge-rate parameter to Device Tree with magic number.
>         V3: Added Device Tree documentatoin and edge-rate parameter table.
>             Added probe function initialize the vsc8531 private datastructure.
> Thanks,
> Raju.
> 
> From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> 
> ---

Please read SubmittingPatches about what the --- means, and what
should be above it and what should be below it.

       Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
