From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] MAINTAINERS: Add networking wireless drivers section
Date: Tue, 28 Jul 2009 11:48:16 -0700
Message-ID: <1248806896.18284.14.camel@Joe-Laptop.home>
References: <Pine.LNX.4.64.0907281753540.28189@ask.diku.dk>
	 <20090728.103044.179053537.davem@davemloft.net>
	 <1248804397.18284.5.camel@Joe-Laptop.home>
	 <20090728.113353.08715297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, julia@diku.dk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1341 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755440AbZG1StE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 14:49:04 -0400
In-Reply-To: <20090728.113353.08715297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-07-28 at 11:33 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 28 Jul 2009 11:06:37 -0700
> 
> > On Tue, 2009-07-28 at 10:30 -0700, David Miller wrote:
> >> Wireless patches need to be CC:'d to linux-wireless so that
> >> John Linville can notice and pick them up
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> Why not just create a plain "WIRELESS" umbrella entry
> that contains all of drivers/net/wireless, net/mac80211,
> and net/wireless?

Whatever works for John I suppose.
John, do you have a preference?

I was trying to avoid the "S: Maintained" label
and was copying the form of this section:

NETWORKING DRIVERS
L:	netdev@vger.kernel.org
W:	http://www.linuxfoundation.org/en/Net
T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
S:	Odd Fixes
F:	drivers/net/


