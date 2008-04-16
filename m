From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Reporting bugs and bisection
Date: Wed, 16 Apr 2008 14:13:04 +0200
Message-ID: <200804161413.05869.rjw@sisk.pl>
References: <47FEADCB.7070104@rtr.ca> <480565D3.6000100@davidnewall.com> <20080416042920.GB25188@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	James Morris <jmorris@namei.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>, david@lang.hm,
	Stephen Clark <sclark46@earthlink.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Tilman Schmidt <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	Mark Lord <lkml@rtr.ca>, David Miller <davem@davemloft.net>,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel <linux-kernel@vger.kernel.org>, git@vger.kernel.org,
	netdev@vger.kernel.org, Andi Kleen <andi@firstfloor.org>
To: Willy Tarreau <w@1wt.eu>, David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:56031 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758246AbYDPMMx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 08:12:53 -0400
In-Reply-To: <20080416042920.GB25188@1wt.eu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, 16 of April 2008, Willy Tarreau wrote:
> On Wed, Apr 16, 2008 at 12:04:59PM +0930, David Newall wrote:
> > Rafael J. Wysocki wrote:
> > > Well, even if someone introduces bugs relatively frequently, but then also
> > > works with the reporters and fixes the bugs timely, it's about okay IMO.
> > >   
> > This really is not okay.  Even if bugs are fixed a version or two later,
> > the impact those bugs have on users makes the system look bad and drives
> > them away.  We do not, I believe, want Linux to top the list for "most
> > bugs".  It's unprofessional, unreliable and quite undesirable.
> 
> that's what -rc are for, and it's unprofessional to use them in production :-)

Exactly.

And BTW, by saying "timely" I meant "in -rc" or "before the next major release".

Thanks,
Rafael
