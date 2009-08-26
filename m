From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 27 Aug 2009 01:58:26 +0200
Message-ID: <20090826235826.GA430@elte.hu>
References: <20090826223922.GA25318@hmsreliant.think-freely.org> <20090826.154410.95005620.davem@davemloft.net> <20090826230514.GB31970@elte.hu> <20090826.160835.263085197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, rostedt@goodmis.org, fweisbec@gmail.com,
	billfink@mindspring.com, netdev@vger.kernel.org, brice@myri.com,
	gallatin@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:41640 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753336AbZHZX6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 19:58:42 -0400
Content-Disposition: inline
In-Reply-To: <20090826.160835.263085197.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Thu, 27 Aug 2009 01:05:14 +0200
> 
> > And the thing is, we are not rigid about these things in the 
> > tracing tree and if this was a good change we would not mind and 
> > you'd have my Ack. The problem is that it's a crappy change and 
> > that Neil is refusing to fix it. So please fix it,
> 
> Thankfully, Steven Rostedt gave a much more useful and reasonable 
> response than you.

I'm sorry you got that impression, but you are a maintainer yourself 
so you might perhaps understand it why sooner or later, if a 
maintainer's review does not get acted upon, one has to insist on 
clean patches in stronger terms.

Unfortunately you took away the "do not apply the patch" option from 
me that could have avoided the stronger words and could have kept 
this discussion more polite.

Thanks,

	Ingo
