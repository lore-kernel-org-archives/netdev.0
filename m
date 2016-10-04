From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Subject: Re: [PATCH v6 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Tue, 4 Oct 2016 19:35:59 +0530
Message-ID: <20161004140557.GA29229@microsemi.com>
References: <1475581272-12093-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20161004115132.GG11677@lunn.ch>
 <20161004122648.GA12301@microsemi.com>
 <20161004125319.GK11677@lunn.ch>
Reply-To: <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161004125319.GK11677-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Thank you for review comments.
I accepted your review comment and change the code.
I resent for code review.

Thanks,
Raju.

On Tue, Oct 04, 2016 at 02:53:19PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> > Regarding remove the -'s in table, PHY data sheet descript the
> > concept of edge rate with table. I would like to keep the same table
> > in driver.
> 
> The double negative makes the code ugly. Plus a negative slowdown is a
> speed up! The kernel maintainability and sanity comes first, and if
> the data sheet is crazy, because it uses negative slows downs, it
> should be ignored. Get the data sheet fixed....
> 
>        Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
