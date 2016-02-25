From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 0/3] bpf_get_stackid() and stack_trace map
Date: Thu, 25 Feb 2016 15:24:54 +0100
Message-ID: <20160225142454.GO6357@twins.programming.kicks-ass.net>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
 <20160220.002505.2066795907514539303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@fb.com, mingo@kernel.org, rostedt@goodmis.org,
	wangnan0@huawei.com, daniel@iogearbox.net,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160220.002505.2066795907514539303.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 20, 2016 at 12:25:05AM -0500, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Wed, 17 Feb 2016 19:58:56 -0800
> 
> > This patch set introduces new map type to store stack traces and
> > corresponding bpf_get_stackid() helper.
>  ...
> 
> Series applied, thanks Alexei.

David, please do not apply perf patches without an ACK from me or mingo.
