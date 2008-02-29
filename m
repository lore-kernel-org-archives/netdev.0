From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] fix boot-time hangs from PREEMPT_RCU and NO_HZ
Date: Fri, 29 Feb 2008 17:57:52 +0100
Message-ID: <20080229165752.GB7952@elte.hu>
References: <Pine.LNX.4.58.0801291113350.20371@gandalf.stny.rr.com> <20080229044329.GA20207@linux.vnet.ibm.com> <20080228210140.37abe9cd.akpm@linux-foundation.org> <20080229154835.GB27248@elte.hu> <20080229165557.GC13330@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	john stultz <johnstul@us.ibm.com>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:37772 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760646AbYB2Q6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 11:58:37 -0500
Content-Disposition: inline
In-Reply-To: <20080229165557.GC13330@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> On Fri, Feb 29, 2008 at 04:48:35PM +0100, Ingo Molnar wrote:
> > 
> > * Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > > Note: This patch came directly from the -rt patch where it has been 
> > > > tested for several months.
> > > > 
> > > > Andrew, could you please apply this?
> > > 
> > > I already have it, via git-sched.  Presumably Ingo has it lined up for 
> > > the next sched-related merge.
> > 
> > yes.
> 
> Ah, thank you both and sorry for the noise!

no, sorry about me taking longer than usual about it - this is not a 
small patch and it had to be observed a bit longer. But as it is usual 
with your patches, it's working perfectly :-)

	Ingo
