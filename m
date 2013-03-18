From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] libertas: drop maintainership
Date: Mon, 18 Mar 2013 12:51:35 -0500
Message-ID: <1363629095.6437.10.camel@dcbw.foobar.com>
References: <1363625321.1597.28.camel@dcbw.foobar.com>
	 <1363627392.2074.21.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Drake <dsd-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>, Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1363627392.2074.21.camel@joe-AO722>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-03-18 at 10:23 -0700, Joe Perches wrote:
> On Mon, 2013-03-18 at 11:48 -0500, Dan Williams wrote:
> > Would be better maintained by somebody who actualy has time for it.
> []
> > diff --git a/MAINTAINERS b/MAINTAINERS
> []
> > -MARVELL LIBERTAS WIRELESS DRIVER
> > -M:	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > -L:	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> > -S:	Maintained
> > -F:	drivers/net/wireless/libertas/
> 
> I think it better to mark it as Orphan
> and maybe leave the list.
> 
> Maybe:
> 
> MARVELL LIBERTAS WIRELESS DRIVER
> L:	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> S:	Orphan
> F:	drivers/net/wireless/libertas/
> 
> or
> 
> MARVELL LIBERTAS WIRELESS DRIVER
> S:	Orphan
> F:	drivers/net/wireless/libertas/

I can do that; I wasn't quite sure how to do this.  A quick check showed
patches that did what mine did, and oddly MAINTAINERS has no section for
dropping maintainership that I could quickly find.  If this is what
others prefer I'm happy to resubmit?

Dan

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
