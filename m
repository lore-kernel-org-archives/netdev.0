From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 27 Aug 2009 01:05:14 +0200
Message-ID: <20090826230514.GB31970@elte.hu>
References: <20090826202344.GE10816@hmsreliant.think-freely.org> <20090826204027.GA21159@elte.hu> <20090826223922.GA25318@hmsreliant.think-freely.org> <20090826.154410.95005620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, rostedt@goodmis.org, fweisbec@gmail.com,
	billfink@mindspring.com, netdev@vger.kernel.org, brice@myri.com,
	gallatin@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:58589 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752077AbZHZXF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 19:05:28 -0400
Content-Disposition: inline
In-Reply-To: <20090826.154410.95005620.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 26 Aug 2009 18:39:22 -0400
> 
> > Ok, I'm rather tired of arguing.  Dave, I'll leave this in your 
> > hands.
> 
> I've gotten this kind of urging, both in private and in public, 
> from both of you now.  And I'm sorry, that's not how this works.
> 
> It is not my job to somehow force you turkeys how to work 
> effectively together. :-)

It is definitely your job to ensure that you do not commit deficient 
patches to kernel/trace/ via the networking tree. You created this 
situation to begin with so you might as well take some 
responsibility and help resolve it.

And the thing is, we are not rigid about these things in the tracing 
tree and if this was a good change we would not mind and you'd have 
my Ack. The problem is that it's a crappy change and that Neil is 
refusing to fix it. So please fix it,

Thanks,

	Ingo
