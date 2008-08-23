From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Sat, 23 Aug 2008 16:11:05 -0700 (PDT)
Message-ID: <944881.4144.qm@web82107.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>,
	Vivek Goyal <vgoyal@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Rufus & Azrael <rufus-azrael@numericable.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82107.mail.mud.yahoo.com ([209.191.84.220]:39183 "HELO
	web82107.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754270AbYHWXLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 19:11:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > Are you experiencing the same difficulties with kernels hanging after
> > version 2.6.25?
> >
> > In my case, kernels before 2.6.26 worked fine, but all kernels since
> > 2.6.26 hang during boot, and the problem was traced (using 'git bisect')
> > to commit number 3def3d6d.
> >
> > Please let me know your situation.
> >
> >
> > Thanks,
> > Dave W.
> >
> >    
> Hello David,
> 
> I have no such hanging on my recent kernels, just the dmesg :
> 
> > [    1.057255] hpet_resources: 0xfed00000 is busy
> and I find the present post to try solving this regression.

OK, thanks.  I thought you might be someone else.  I found another person
having the hang regression, and invited him to participate here.  I guess
you're not that person....


DW
