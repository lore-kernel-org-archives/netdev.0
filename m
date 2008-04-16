From: Willy Tarreau <w@1wt.eu>
Subject: Re: Reporting bugs and bisection
Date: Wed, 16 Apr 2008 06:29:20 +0200
Message-ID: <20080416042920.GB25188@1wt.eu>
References: <47FEADCB.7070104@rtr.ca> <517f3f820804150254w491cdf85s28f1d15696db8d96@mail.gmail.com> <4804B5D5.4090404@davidnewall.com> <200804152251.51308.rjw@sisk.pl> <480565D3.6000100@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	James Morris <jmorris@namei.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>, david@lang.hm,
	Stephen Clark <sclark46@earthlink.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Tilman Schmidt <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	Mark Lord <lkml@rtr.ca>, David Miller <davem@davemloft.net>,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel <linux-kernel@vger.kernel.org>, git@vger.kernel.org,
	netdev@vger.kernel.org
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:3139 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750850AbYDPEop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 00:44:45 -0400
Content-Disposition: inline
In-Reply-To: <480565D3.6000100@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 16, 2008 at 12:04:59PM +0930, David Newall wrote:
> Rafael J. Wysocki wrote:
> > Well, even if someone introduces bugs relatively frequently, but then also
> > works with the reporters and fixes the bugs timely, it's about okay IMO.
> >   
> This really is not okay.  Even if bugs are fixed a version or two later,
> the impact those bugs have on users makes the system look bad and drives
> them away.  We do not, I believe, want Linux to top the list for "most
> bugs".  It's unprofessional, unreliable and quite undesirable.

that's what -rc are for, and it's unprofessional to use them in production :-)

