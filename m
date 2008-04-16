From: David Newall <davidn@davidnewall.com>
Subject: Re: Reporting bugs and bisection
Date: Wed, 16 Apr 2008 12:04:59 +0930
Message-ID: <480565D3.6000100@davidnewall.com>
References: <47FEADCB.7070104@rtr.ca> <517f3f820804150254w491cdf85s28f1d15696db8d96@mail.gmail.com> <4804B5D5.4090404@davidnewall.com> <200804152251.51308.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	James Morris <jmorris@namei.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>, david@lang.hm,
	Stephen Clark <sclark46@earthlink.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Tilman Schmidt <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	Mark Lord <lkml@rtr.ca>, David Miller <davem@davemloft.net>,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel <linux-kernel@vger.kernel.org>, git@vger.kernel.org,
	netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth7959.sa.adsl.internode.on.net ([150.101.82.22]:33211 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752951AbYDPCfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 22:35:01 -0400
In-Reply-To: <200804152251.51308.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafael J. Wysocki wrote:
> Well, even if someone introduces bugs relatively frequently, but then also
> works with the reporters and fixes the bugs timely, it's about okay IMO.
>   
This really is not okay.  Even if bugs are fixed a version or two later,
the impact those bugs have on users makes the system look bad and drives
them away.  We do not, I believe, want Linux to top the list for "most
bugs".  It's unprofessional, unreliable and quite undesirable.
