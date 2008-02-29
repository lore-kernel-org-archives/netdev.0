From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] fix boot-time hangs from PREEMPT_RCU and NO_HZ
Date: Fri, 29 Feb 2008 12:08:29 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0802291207250.30943@gandalf.stny.rr.com>
References: <Pine.LNX.4.58.0801291113350.20371@gandalf.stny.rr.com>
 <20080229044329.GA20207@linux.vnet.ibm.com> <20080228210140.37abe9cd.akpm@linux-foundation.org>
 <20080229154835.GB27248@elte.hu> <20080229165557.GC13330@linux.vnet.ibm.com>
 <20080229165752.GB7952@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	john stultz <johnstul@us.ibm.com>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.123]:35572 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761181AbYB2RIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 12:08:34 -0500
In-Reply-To: <20080229165752.GB7952@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 29 Feb 2008, Ingo Molnar wrote:
>
> no, sorry about me taking longer than usual about it - this is not a
> small patch and it had to be observed a bit longer. But as it is usual
> with your patches, it's working perfectly :-)

Not to mention that this patch has been in the -rt tree for some time now.
But you are right, it's a pretty big patch to go in without shaking it out
further.

Good to know that I hasn't needed any tweaks in the bigger arena.

-- Steve

