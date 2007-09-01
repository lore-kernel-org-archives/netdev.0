From: "Constantine A. Murenin" <mureninc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sat, 1 Sep 2007 17:27:03 -0400
Message-ID: <f34ca13c0709011427u7a9cc97bp75c035afed3e5a63@mail.gmail.com>
References: <200709010140.l811eq9H005896@cvs.openbsd.org>
	 <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com>
	 <46D99FB7.6030505@garzik.org>
	 <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com>
	 <20070901205457.GK9260@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Adrian Bunk" <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070901205457.GK9260-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/09/07, Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Sat, Sep 01, 2007 at 01:37:18PM -0400, Constantine A. Murenin wrote:
> > On 01/09/07, Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org> wrote:
> > > Constantine A. Murenin wrote:
> > > > This will hopefully help diminish certain myths about the code licensing.
> > >
> > > What myth?  The myth that Theo understands dual licensing?
> >
> > Reyk's code was never dual licensed, so it's not like it even matters
> > to the original dispute.
>
> It's no longer dual licenced in the FreeBSD tree because the FreeBSD
> people removed the GPL choice of the dual licenced code 3 months ago.

FreeBSD doesn't have Reyk's ath(4) HAL, which OpenHAL is based on.

FreeBSD has a driver written by Sam, and a binary-only HAL, also written by Sam.

> So all of Theo's accusations of people breaking the law by making this
> dual licenced code GPL-only apply as well to the FreeBSD people...

How? FreeBSD doesn't have Reyk's ath(4) HAL from OpenBSD, so there are
no possible licensing accusations and violations.

> > That said, I don't see what exact wording you consider inaccurate.
>
> Both the FreeBSD and Linux people draw the logical conclusion that this
> "Alternatively" means everyone can always choose to remove one of the
> two choices alternatively offered.
>
> According to Theo, that is "breaking the law"...

FreeBSD's ath(4) code, both the driver and the HAL, is entirely
written by Sam Leffler, who can licence it in whichever way he seems
reasonable. The driver part of Sam's code is also present in OpenBSD,
but the HALs in OpenBSD and FreeBSD are entirely different.

C.
