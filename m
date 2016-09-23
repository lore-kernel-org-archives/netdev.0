From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Fri, 23 Sep 2016 13:53:33 +0200
Message-ID: <20160923115333.GJ5008@twins.programming.kicks-ass.net>
References: <20160831164216.2901190c@redhat.com>
 <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160901.233913.237544263411665891.davem@davemloft.net>
 <57E5139F.5040708@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        riel@redhat.com, pabeni@redhat.com, hannes@redhat.com,
        jbrouer@redhat.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, corbet@lwn.net,
        Ingo Molnar <mingo@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:48960 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965339AbcIWLxp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 07:53:45 -0400
Content-Disposition: inline
In-Reply-To: <57E5139F.5040708@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 01:35:59PM +0200, Daniel Borkmann wrote:
> On 09/02/2016 08:39 AM, David Miller wrote:
> >
> >I'm just kind of assuming this won't go through my tree, but I can take
> >it if that's what everyone agrees to.
> 
> Was this actually picked up somewhere in the mean time?

I can queue it for tip. In fact, I've just done so to avoid loosing it.
If anybody else wants it holler.
