From: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sun, 2 Sep 2007 02:09:13 +0200
Message-ID: <20070902000913.GB16016@stusta.de>
References: <200709010140.l811eq9H005896@cvs.openbsd.org> <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com> <46D99FB7.6030505@garzik.org> <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com> <20070901205457.GK9260@stusta.de> <f34ca13c0709011427u7a9cc97bp75c035afed3e5a63@mail.gmail.com> <20070901215225.GM9260@stusta.de> <f34ca13c0709011629g1f16508cic7c31c3d20a57dae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
To: "Constantine A. Murenin" <mureninc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <f34ca13c0709011629g1f16508cic7c31c3d20a57dae-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 01, 2007 at 07:29:39PM -0400, Constantine A. Murenin wrote:
> On 01/09/07, Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> > On Sat, Sep 01, 2007 at 05:27:03PM -0400, Constantine A. Murenin wrote:
> > > On 01/09/07, Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> > > > On Sat, Sep 01, 2007 at 01:37:18PM -0400, Constantine A. Murenin wrote:
> > > > > On 01/09/07, Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org> wrote:
> > > > > > Constantine A. Murenin wrote:
> > > > > > > This will hopefully help diminish certain myths about the code licensing.
> > > > > >
> > > > > > What myth?  The myth that Theo understands dual licensing?
> > > > >
> > > > > Reyk's code was never dual licensed, so it's not like it even matters
> > > > > to the original dispute.
> > > >
> > > > It's no longer dual licenced in the FreeBSD tree because the FreeBSD
> > > > people removed the GPL choice of the dual licenced code 3 months ago.
> > >
> > > FreeBSD doesn't have Reyk's ath(4) HAL, which OpenHAL is based on.
> > >
> > > FreeBSD has a driver written by Sam, and a binary-only HAL, also written by Sam.
> > >
> > > > So all of Theo's accusations of people breaking the law by making this
> > > > dual licenced code GPL-only apply as well to the FreeBSD people...
> > >
> > > How? FreeBSD doesn't have Reyk's ath(4) HAL from OpenBSD, so there are
> > > no possible licensing accusations and violations.
> >
> > OK, I begin to understand this, there seem to be three different types
> > of files changed by Jiri's patch:
> > 1. dual licenced files planned to make GPL-only
> > 2. previously dual licenced files with a too recent version used planned
> >    to make GPL-only
> > 3. never dual licenced files planned to make GPL-only
> >
> > For files under 1. and 2. Reyk did contribute to dual licenced code
> > without touching the licence, but I missed that there's also code unter 3.
> >
> > So there is a problem, but not with the code under 1. (unless you plan
> > to change the semantics of the word "alternatively"), the problem is
> > with some headers under 2. plus the code under 3.
> >
> > It's funny how Theo missed the part of Jiri's patch that actually is a
> > copyright violation and instead complains about the part that is OK...
> 
> I'm not sure how you conclude that Theo missed the relevant parts --
> there were many messages posted to misc-7YlrpqBBQ3VAfugRpC6u6w@public.gmane.org mailing list and
> to The OpenBSD Journal in the last few days, and to me it appears as
> all of the problems were discussed ad nauseam.
>...

Then it's your fault that you forwarded the wrong email - in the email 
you forwarded the only action for which Theo accused the Linux 
developers of breaking the law was for choosing one licence when using 
dual licenced code.

> After the obvious copyright violations were addressed, I think the
> problem started being an ethical one.
> 
> As a free software user and developer, the question I have is how come
> the Linux community feels that they can take the BSD code that was
> reverse-engineered at OpenBSD, and put a more restrictive licence onto
> it, such that there will be no possibility of the changes going back
> to OpenBSD, given that the main work on the code has happened at
> OpenBSD? (Obviously, such a scenario it is permitted by the licence,
> but my question is an ethical one -- after all, most components of
> OpenHAL were specifically based on the OpenBSD's ath(4) HAL code.)
> 
> You can see that Christoph Hellwig agrees with this ethical problem,
> as in the message below.

Is it a legal problem or is it "only" an ethical problem?

If choosing one licence when using dual licenced code is not a legal 
problem then Theo repeatedly talking about it would "break the law" in 
the email you forwarded was very unethical and the worst he could do
for his cause.

> C.
>...

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
