From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Fri, 23 Sep 2016 18:51:04 +0200
Message-ID: <20160923185104.535813b4@redhat.com>
References: <20160831164216.2901190c@redhat.com>
        <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
        <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160901.233913.237544263411665891.davem@davemloft.net>
        <57E5139F.5040708@iogearbox.net>
        <20160923115333.GJ5008@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        riel@redhat.com, pabeni@redhat.com, hannes@redhat.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        corbet@lwn.net, Ingo Molnar <mingo@kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160923115333.GJ5008@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Sep 2016 13:53:33 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Fri, Sep 23, 2016 at 01:35:59PM +0200, Daniel Borkmann wrote:
> > On 09/02/2016 08:39 AM, David Miller wrote:  
> > >
> > >I'm just kind of assuming this won't go through my tree, but I can take
> > >it if that's what everyone agrees to.  
> > 
> > Was this actually picked up somewhere in the mean time?  
> 
> I can queue it for tip. In fact, I've just done so to avoid loosing it.
> If anybody else wants it holler.

Good that you are picking this up! It is a very important fix, as least
for networking.

This is your git tree, right:
 https://git.kernel.org/cgit/linux/kernel/git/peterz/queue.git/

Doesn't look like you pushed it yet, or do I need to look at a specific
branch?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
