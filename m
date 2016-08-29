From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/6] perf, bpf: add support for bpf in sw/hw
 perf_events
Date: Mon, 29 Aug 2016 16:08:55 -0700
Message-ID: <20160829230853.GA52376@ast-mbp.thefacebook.com>
References: <1472265084-1767670-1-git-send-email-ast@fb.com>
 <20160829105800.GM10153@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160829105800.GM10153@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 29, 2016 at 12:58:00PM +0200, Peter Zijlstra wrote:
> On Fri, Aug 26, 2016 at 07:31:18PM -0700, Alexei Starovoitov wrote:
> > Hi Peter, Dave,
> > 
> > this patch set is a follow up to the discussion:
> > https://lkml.org/lkml/2016/8/4/304
> 
> Please don't use lkml.org links, that site is broken too often.
> 
> The canonical reference is:
> 
>   https://lkml.kernel.org/r/$MSGID
> 
> That allows the kernel.org people to ensure the links stays valid by
> redirecting to a functional archive if the current one (marc.info) were
> to drop off the intarweb.
> 
> Also, by including the msg-id, people can find the emails in their local
> archives.

Makes sense though I couldn't figure out how to find that msg-id.
This one
https://lkml.kernel.org/r/20160804142853.GO6862%20()%20twins%20!%20programming%20!%20kicks-ass%20!%20net
works, but really ugly.
