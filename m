From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Subject: Re: [PATCH v3 net-next] net: phy: Add LED mode driver for Microsemi
 PHYs.
Date: Thu, 16 Feb 2017 14:36:48 +0530
Message-ID: <20170216090646.GA29082@microsemi.com>
References: <1486474826-29426-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20170215164540.eok7bnudfffzoyi4@rob-hp-laptop>
Reply-To: <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>,
        <andrew-g2DYL2Zd6BY@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170215164540.eok7bnudfffzoyi4@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rob,

On Wed, Feb 15, 2017 at 10:45:40AM -0600, Rob Herring wrote:
> EXTERNAL EMAIL
> 
> 
> On Tue, Feb 07, 2017 at 07:10:26PM +0530, Raju Lakkaraju wrote:
> > From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> >
> > +                       Default value is VSC8531_LINK_1000_ACTIVITY (1).
> > +- vsc8531,led-1-mode : LED mode. Specify how the LED[1] should behave.
> 
> You failed to address my comment on v2. vsc8531 is not a vendor prefix.
> Please fix in a new patch since David already applied it.
> 

Accpeted my fault. i missed your comment.
Do i need to change from  "vsc8531, led-0-mode" to "mscc, led-0-mode"
Is this your suggestion?

> Rob

---
Thanks,
Raju.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
