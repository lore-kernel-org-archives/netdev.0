From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 net-next 0/6] perf, bpf: add support for bpf in sw/hw
 perf_events
Date: Fri, 2 Sep 2016 11:32:34 +0200
Message-ID: <20160902093234.GM10138@twins.programming.kicks-ass.net>
References: <1472780246-323814-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:51372 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751752AbcIBJct (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 05:32:49 -0400
Content-Disposition: inline
In-Reply-To: <1472780246-323814-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2016 at 06:37:20PM -0700, Alexei Starovoitov wrote:
> Peter,
> to implement your suggestion to add ifdef CONFIG_BPF_SYSCALL
> inside struct perf_event, I had to shuffle ifdefs in events/core.c
> Please double check whether that is what you wanted to see.

Looks fine, Thanks!

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
