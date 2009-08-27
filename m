From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 20:05:04 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0908262002050.11291@gandalf.stny.rr.com>
References: <20090826223922.GA25318@hmsreliant.think-freely.org> <20090826.154410.95005620.davem@davemloft.net> <20090826230514.GB31970@elte.hu> <20090826.160835.263085197.davem@davemloft.net> <20090826235826.GA430@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	fweisbec@gmail.com, billfink@mindspring.com,
	netdev@vger.kernel.org, brice@myri.com, gallatin@myri.com
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.123]:39486 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbZH0AFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 20:05:04 -0400
In-Reply-To: <20090826235826.GA430@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 27 Aug 2009, Ingo Molnar wrote:

> 
> * David Miller <davem@davemloft.net> wrote:
> 
> > From: Ingo Molnar <mingo@elte.hu>
> > Date: Thu, 27 Aug 2009 01:05:14 +0200
> > 
> > > And the thing is, we are not rigid about these things in the 
> > > tracing tree and if this was a good change we would not mind and 
> > > you'd have my Ack. The problem is that it's a crappy change and 
> > > that Neil is refusing to fix it. So please fix it,
> > 
> > Thankfully, Steven Rostedt gave a much more useful and reasonable 
> > response than you.
> 
> I'm sorry you got that impression, but you are a maintainer yourself 
> so you might perhaps understand it why sooner or later, if a 
> maintainer's review does not get acted upon, one has to insist on 
> clean patches in stronger terms.
> 
> Unfortunately you took away the "do not apply the patch" option from 
> me that could have avoided the stronger words and could have kept 
> this discussion more polite.

I feel somewhat at fault here. Neil did give me a heads up on his project, 
but his patches went out when I was getting ready for vacation and had 
other priorities at the time. I could have brought up these issues before 
Dave took them, and he may have taken them because I did not.

But this is all water under the bridge. Time to be more productive.

-- Steve

