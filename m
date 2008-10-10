From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 10 Oct 2008 13:57:25 +0200
Message-ID: <20081010115725.GD19487@elte.hu>
References: <20081009231759.GA8664@tservice.net.ru> <20081010080910.GA31723@tservice.net.ru> <20081010091511.GC5116@elte.hu> <20081010113100.GA1030@tservice.net.ru> <20081010114245.GB19487@elte.hu> <20081010115518.GA3159@tservice.net.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Mike Galbraith <efault@gmx.de>
To: Evgeniy Polyakov <s0mbre@tservice.net.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759345AbYJJL5t@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081010115518.GA3159@tservice.net.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Evgeniy Polyakov <s0mbre@tservice.net.ru> wrote:

> On Fri, Oct 10, 2008 at 01:42:45PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> > > vanilla 27: 347.222
> > > no TSO/GSO: 357.331
> > > no hrticks: 382.983
> > > no balance: 389.802
> > 
> > okay. The target is 470 MB/sec, right? (Assuming the workload is sane 
> > and 'fixing' it does not mean we have to schedule worse.)
> 
> Well, that's where I started/stopped, so maybe we will even move
> further? :)

that's the right attitude ;)

	Ingo
