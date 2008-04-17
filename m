From: "Sverre Rabbelier" <alturin@gmail.com>
Subject: Re: Reporting bugs and bisection
Date: Thu, 17 Apr 2008 21:57:06 +0200
Message-ID: <bd6139dc0804171257l5f875694yb57105ba40170789@mail.gmail.com>
References: <47FEADCB.7070104@rtr.ca>
	 <9a8748490804161417n4ad6c1den54ccd302831a66c6@mail.gmail.com>
	 <48078323.4010109@davidnewall.com> <200804172109.35027.rjw@sisk.pl>
	 <2c0942db0804171235o49238b99u6cdbd3e5c8d6ebb7@mail.gmail.com>
Reply-To: sverre@rabbelier.nl
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"David Newall" <davidn@davidnewall.com>,
	"Jesper Juhl" <jesper.juhl@gmail.com>, git@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"James Morris" <jmorris@namei.org>,
	"Al Viro" <viro@zeniv.linux.org.uk>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Willy Tarreau" <w@1wt.eu>, david@lang.hm,
	"Stephen Clark" <sclark46@earthlink.net>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Tilman Schmidt" <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	"Mark Lord" <lkml@rtr.ca>, "David Miller" <davem@davemloft.net>,
	yoshfuji@linux-ipv6.org, jeff@garzik.org, netdev@vger.kernel.org
To: "Ray Lee" <ray-lk@madrabbit.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753931AbYDQT5k@vger.kernel.org>
In-Reply-To: <2c0942db0804171235o49238b99u6cdbd3e5c8d6ebb7@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 17, 2008 at 9:35 PM, Ray Lee <ray-lk@madrabbit.org> wrote:
> On Thu, Apr 17, 2008 at 12:09 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>  >  > Finger-pointing, in these extreme cases, gives incentive to improve
>  >  > quality.  It's a positive thing.
>  >
>  >  Sorry, but I have to disagree.  Negative finger-pointing is never a good thing.
>
>  Correct, but let's be careful here. The original suggestion was,
>  effectively, to get better metrics on the quality of contributions.
>  Those metrics *could* be used for finger pointing, or (my preference)
>  they could be used to direct and allocate our scarce resources: code
>  reviews and mentoring.

Exactly!

>  There's no way to know what the metrics will tell us until we have
>  them. Arguing against metrics because they *may* be used to point
>  fingers at people is a silly argument; anything can be subverted to do
>  that.

Thank you, that should have been said before, you worded it perfectly.

>  Let's get some measurements and see what they say. In the meantime,
>  try to believe that they could be put to good purposes, such as
>  identifying code areas that are tricky for contributors to get right
>  (independent of contributor), or contributors that could benefit from
>  code reviews, etc.

This especially is an area that I plan to focus on and should be very
reliable when finished. As can be read in my application, I plan to
look at how often a piece of code is changed, in what timespan and by
how many different authors.

Thanks for the reply!

Cheers,

Sverre
