From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: Reporting bugs and bisection
Date: Thu, 17 Apr 2008 13:38:18 -0700
Message-ID: <2c0942db0804171338p7bc7d9f2u8079c2f8c8998e76@mail.gmail.com>
References: <47FEADCB.7070104@rtr.ca>
	 <9a8748490804161417n4ad6c1den54ccd302831a66c6@mail.gmail.com>
	 <48078323.4010109@davidnewall.com> <200804172109.35027.rjw@sisk.pl>
	 <2c0942db0804171235o49238b99u6cdbd3e5c8d6ebb7@mail.gmail.com>
	 <20080417201657.GF27459@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"David Newall" <davidn@davidnewall.com>,
	"Jesper Juhl" <jesper.juhl@gmail.com>, sverre@rabbelier.nl,
	git@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>,
	"James Morris" <jmorris@namei.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Willy Tarreau" <w@1wt.eu>, david@lang.hm,
	"Stephen Clark" <sclark46@earthlink.net>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Tilman Schmidt" <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	"Mark Lord" <lkml@rtr.ca>, "David Miller" <davem@davemloft.net>,
	yoshfuji@linux-ipv6.org, jeff@garzik.org, netdev@vger.kernel.org
To: "Al Viro" <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0708.google.com ([209.85.198.244]:1833 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753486AbYDQUiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 16:38:19 -0400
Received: by rv-out-0506.google.com with SMTP id k29so116890rvb.1
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 13:38:18 -0700 (PDT)
In-Reply-To: <20080417201657.GF27459@ZenIV.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 17, 2008 at 1:16 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Thu, Apr 17, 2008 at 12:35:12PM -0700, Ray Lee wrote:
>  > On Thu, Apr 17, 2008 at 12:09 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>  > >  > Finger-pointing, in these extreme cases, gives incentive to improve
>  > >  > quality.  It's a positive thing.
>  > >
>  > >  Sorry, but I have to disagree.  Negative finger-pointing is never a good thing.
>  >
>  > Correct, but let's be careful here. The original suggestion was,
>  > effectively, to get better metrics on the quality of contributions.
>
>         There already is one: reputation with people working on the tree,
>  be it actively modifying/reviewing/bug hunting/etc.  _We_ _already_ _know_;

Sigh. No, you already know. I don't. This is not a rhetorical point.
I've just bid out another project that'd involve getting linux running
on another embedded hardware platform. If that happens, I get to spend
paid time to work on the kernel, and as a by-product spend more time
looking at patches and code coming across the list.

So, where would it be best to spend my time? Or anyone else's?

>  generally one gets a decent idea of what to expect pretty soon.
>
>         And frankly, that's the only thing that matters anyway; I suspect
>  I'd do rather well by proposed criteria, but you know what?  I don't give
>  a flying f*ck through the rolling doughnut for self-appointed PHBs and
>  their idea of performance reviews.

(Geez, conflate the issue much?) No one is saying you should. But
also, I haven't seen anyone saying it'd be used for performance
reviews other than you.

>         Think of it as a modified Turing test: convince me that you are
>  not a script piped through an Eng.Lit. wanker or an MBA, then I might care
>  for your opinion.

<shrug> Shockingly enough, I actually don't care. I'm just trying to
scratch my own itch, which is figure out where in the kernel (if
anywhere!) it'd be best to donate my time.

And your point is likely about the metrics, and yes, they'll be
computer generated. So? Perhaps they'll be crap. Who knows until we
look at them and match them up with what everyone already knows? If,
by some one in a thousand chance, they turn out to be good and useful,
then it'll either be a one-off eye-opener, or perhaps something useful
more than once.

Who knows? And to the larger point, why put effort into stopping
someone else from finding out?

>         Al, who never had problems with pointing fingers and laughing, but
>  likes an informed human brain to be the source of it...

<shrug> Shame and Guilt, two major motivators of human behavior, it's
true. But, one last time, *you're* the one saying the stats would be
used for finger pointing at people. Perhaps, instead, the stats will
show that we should all collectively point our fingers at some random
area in the tree, where everyone, despite their track record, ends up
making mistakes.

Let the kid find out, that's all I'm saying.
