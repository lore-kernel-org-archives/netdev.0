From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] dt-binding: net/phy: fix interrupts description
Date: Tue, 29 Aug 2017 12:15:34 -0500
Message-ID: <20170829171534.rjgf77nub2ub3msf@rob-hp-laptop>
References: <b3756346473feadfeba70ecb71960cad48e66621.1503468660.git.baruch@tkos.co.il>
 <20170828102039.wdylojqcrn2avv2f@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
To: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170828102039.wdylojqcrn2avv2f@tarshish>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2017 at 01:20:39PM +0300, Baruch Siach wrote:
> Hi Dave,
> 
> On Wed, Aug 23, 2017 at 09:11:00AM +0300, Baruch Siach wrote:
> > Commit b053dc5a722ea (powerpc: Refactor device tree binding) split the
> > Ethernet PHY binding documentation out of the big booting-without-of.txt
> > file, leaving a dangling reference to "section 2" in the 'interrupts'
> > property description. Drop that reference, and make the description look
> > more like the rest.
> > 
> > While at it, make the example interrupt-parent phandle look more like a
> > real world phandle, and use an IRQ_TYPE_ macro for the 'interrupts'
> > type.
> 
> This patch is now marked 'Not Applicable' in the netdev patchwork. Why is 
> that? Should it go through some other tree?

If it is only a binding change, I can apply. Though David does often 
pick them up anyway.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
