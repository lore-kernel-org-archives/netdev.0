From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: zd1211 ported to Devicescape stack
Date: Sat, 2 Dec 2006 20:53:34 +0100
Message-ID: <20061202195334.GA6080@p15091797.pureserver.info>
References: <200612020316.50965.flamingice@sourmilk.net> <4571A295.4030700@gentoo.org> <20061202175737.GA5577@p15091797.pureserver.info> <4571CC0C.2070309@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Luis Rodriguez <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:25557 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1424164AbWLBTxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 14:53:35 -0500
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <4571CC0C.2070309@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-12-02 13:55 Daniel Drake wrote:

> Ulrich Kunitz wrote:
> >I intend to track the d80211 stack, care for the forward porting
> >and see also a number of things, which should be done for d80211.
> 
> OK, sorry for the false assumptions in my last mail.

It's true, I have not much time during the week to work on it. But
a few hours over the weekend are always possible.

> In that case, I guess we should both switch to developing zd1211rw on 
> d80211 primarily. I am still interested in seeing stuff in mainline so I 
> will spend time backporting some of the new developments (but nothing 
> major).

That's ok. However I wouldn't like to step back from changes
simply to make backporting easier. It doesn't feel like things are
handled in the kernel.

> We should also use this opportunity to switch to developing in kernel 
> git trees (as opposed to external kernel module git trees) for the 
> d80211 port.

It shouldn't surprise you that I'm in violent agreement.

> To start with, I would ask you to pull my git tree then John (or 
> Michael?) would pull from you. We should start this at the point when 
> Michael's port enters wireless-dev.git
> 
> What do you think?

I really liked the way it worked out between both of us. I think
the master branch worked pretty well and we hadn't a lot of
arguments about changes, which were put in there. So I wouldn't
mind if you would continue to handle the upstream also for d80211.
But for now I could agree to maintain the upstream branch. It
it works exactly well between the three of us, Michael could take
over that task also. 

Michael do you agree on a common upstream branch, which only
contains agreed patches?

-- 
Uli Kunitz
