From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: A couple of fixes and cleanups
Date: Mon, 11 Aug 2008 22:57:51 +1000
Message-ID: <20080811125749.GC19965@verge.net.au>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net> <alpine.LNX.1.10.0808102032180.12259@titan.stealer.net> <alpine.LNX.1.10.0808111416350.12259@titan.stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wensong@linux-vs.org, ja@ssi.bg, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39822 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbYHKM5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 08:57:54 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808111416350.12259@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 02:19:47PM +0200, Sven Wegener wrote:
> On Sun, 10 Aug 2008, Sven Wegener wrote:
> 
> > On Sun, 10 Aug 2008, sven.wegener@stealer.net wrote:
> > 
> > > Hi guys,
> > > 
> > > here come a couple of fixes and cleanups for IPVS. Worth mentioning are the two
> > > possible deadlock fixes. One introduced by my last sync daemon work, which
> > > hasn't hit any stable kernel yet. The other one is in the estimator code and
> > > goes back to at leat since we started working with git for the kernel. The
> > > latter I think qualifies for -stable.
> > > 
> > > I've pushed the changes (8123b42..2e45552) based on davem's net tree here
> > > 
> > > 	git://git.stealer.net/linux-2.6.git stealer/ipvs/for-davem
> > 
> > I've included the register_ip_vs_protocol() annotation. Changes are now 
> > 8123b42..7ead17b. Diffstat has changed slightly, but is probably not worth 
> > posting again.
> 
> OK, this should be final now. I've pushed the changes 8123b42..e93615d to
> 
> 	git://git.stealer.net/linux-2.6.git stealer/ipvs/for-davem
> 
> Simon, as you see I've included your patch and added your acked-by onto 
> the other patches.

Thanks. Everything looks in order to me.
