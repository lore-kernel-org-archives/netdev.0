From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 0/6] perf, bpf: add support for bpf in sw/hw
 perf_events
Date: Mon, 29 Aug 2016 12:58:00 +0200
Message-ID: <20160829105800.GM10153@twins.programming.kicks-ass.net>
References: <1472265084-1767670-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472265084-1767670-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 26, 2016 at 07:31:18PM -0700, Alexei Starovoitov wrote:
> Hi Peter, Dave,
> 
> this patch set is a follow up to the discussion:
> https://lkml.org/lkml/2016/8/4/304

Please don't use lkml.org links, that site is broken too often.

The canonical reference is:

  https://lkml.kernel.org/r/$MSGID

That allows the kernel.org people to ensure the links stays valid by
redirecting to a functional archive if the current one (marc.info) were
to drop off the intarweb.

Also, by including the msg-id, people can find the emails in their local
archives.
