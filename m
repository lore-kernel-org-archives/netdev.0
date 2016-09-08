From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH, net-next] perf, bpf: fix conditional call to
 bpf_overflow_handler
Date: Thu, 8 Sep 2016 09:01:13 +0200
Message-ID: <20160908070113.GA3003@gmail.com>
References: <20160906131033.1784262-1-arnd@arndb.de>
 <20160906153349.GA38225@ast-mbp.thefacebook.com>
 <20160908063052.GA24253@gmail.com>
 <20160908065650.GW10138@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@kernel.org>,
        Ingo Molnar <mingo@redhat.com>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Alexei Starovoitov <ast@fb.com>, linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160908065650.GW10138@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Sep 08, 2016 at 08:30:52AM +0200, Ingo Molnar wrote:
> > > Thanks for the fix. Just saw build bot complaining last night and
> > > by the morning your fix is already here. Thanks!
> > 
> > Guys, this is the first time I saw this patch (and presumably there's some other 
> > patch as well?) - could you please submit it properly for review and get an 
> > Acked-by from one of the perf maintainers before appying it?
> 
> I was involved with the original patch and Ack'ed it.

Neither the Ack nor the Cc:s were preserved in the net-next commit:

  aa6a5f3cb2b2 ("perf, bpf: add perf events core support for BPF_PROG_TYPE_PERF_EVENT programs")

> Ack on this one as well.

Great, thanks!

	Ingo
