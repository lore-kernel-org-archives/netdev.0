From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Fri, 23 Sep 2016 23:16:16 +0200
Message-ID: <20160923211616.GF5012@twins.programming.kicks-ass.net>
References: <20160831164216.2901190c@redhat.com>
 <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160901.233913.237544263411665891.davem@davemloft.net>
 <57E5139F.5040708@iogearbox.net>
 <20160923115333.GJ5008@twins.programming.kicks-ass.net>
 <20160923185104.535813b4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        riel@redhat.com, pabeni@redhat.com, hannes@redhat.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        corbet@lwn.net, Ingo Molnar <mingo@kernel.org>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160923185104.535813b4@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 23, 2016 at 06:51:04PM +0200, Jesper Dangaard Brouer wrote:

> This is your git tree, right:
>  https://git.kernel.org/cgit/linux/kernel/git/peterz/queue.git/
> 
> Doesn't look like you pushed it yet, or do I need to look at a specific
> branch?

I mainly work from a local quilt queue which I feed to mingo. I
occasionally push out to get build-bot coverage or have people look at
bits I poked together.

That said, I'll try and do a push later tonight.

Do note however, that git tree is a complete wipe and rebuild, don't
expect any kind of continuity from it.
