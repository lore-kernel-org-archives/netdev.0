From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 27 Aug 2009 11:28:41 +0200
Message-ID: <20090827092841.GC4260@elte.hu>
References: <20090826223922.GA25318@hmsreliant.think-freely.org> <20090826.154410.95005620.davem@davemloft.net> <20090826230514.GB31970@elte.hu> <20090826.160835.263085197.davem@davemloft.net> <20090826235826.GA430@elte.hu> <20090827003536.GC30341@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	rostedt@goodmis.org, fweisbec@gmail.com, billfink@mindspring.com,
	netdev@vger.kernel.org, brice@myri.com, gallatin@myri.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:42418 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751946AbZH0J2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 05:28:54 -0400
Content-Disposition: inline
In-Reply-To: <20090827003536.GC30341@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Aug 27, 2009 at 01:58:26AM +0200, Ingo Molnar wrote:
>
> > I'm sorry you got that impression, but you are a maintainer 
> > yourself so you might perhaps understand it why sooner or later, 
> > if a maintainer's review does not get acted upon, one has to 
> > insist on clean patches in stronger terms.
> 
> Cool down a bit :) [...]

Hello Pot, Kettle here ;-)

I guess i'll have to test the limits of your patience by queueing up 
some bad commit into fs/libfs.c via say the iommu tree, without acks 
and with commit log damage, which patch then triggers a build 
failure and a crash in linux-next (like this one did), and refuse to 
revert and not do anything substantial about your (initially polite) 
review feedback for 2 weeks (like it happened here), and see how 
measured your response will be after the 12th mail that gets faced 
with such passive-aggressive inaction ;-)

At that point, will your wall of patience finally start to crumble a 
tiny bit and will you resort to using the taboo term 'crappy patch' 
perhaps, like i did here? ;-)

Anyway, as Steve said it's now finally water under the bridge, time 
to move on.

	Ingo
