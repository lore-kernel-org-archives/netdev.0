From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sat, 25 Oct 2008 00:25:34 +0200
Message-ID: <200810250025.35734.rjw@sisk.pl>
References: <20081009231759.GA8664@tservice.net.ru> <20081010115518.GA3159@tservice.net.ru> <20081010115725.GD19487@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <s0mbre@tservice.net.ru>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Mike Galbraith <efault@gmx.de>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:48334 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756622AbYJXWVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 18:21:15 -0400
In-Reply-To: <20081010115725.GD19487@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, 10 of October 2008, Ingo Molnar wrote:
> 
> * Evgeniy Polyakov <s0mbre@tservice.net.ru> wrote:
> 
> > On Fri, Oct 10, 2008 at 01:42:45PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> > > > vanilla 27: 347.222
> > > > no TSO/GSO: 357.331
> > > > no hrticks: 382.983
> > > > no balance: 389.802
> > > 
> > > okay. The target is 470 MB/sec, right? (Assuming the workload is sane 
> > > and 'fixing' it does not mean we have to schedule worse.)
> > 
> > Well, that's where I started/stopped, so maybe we will even move
> > further? :)
> 
> that's the right attitude ;)

Can anyone please tell me if there was any conclusion of this thread?

Thanks,
Rafael
