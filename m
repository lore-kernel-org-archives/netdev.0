From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next] perf, bpf: minimize the size of perf_trace_()
 tracepoint handler
Date: Thu, 21 Apr 2016 10:12:51 -0400
Message-ID: <20160421101251.2b3604b6@gandalf.local.home>
References: <1461035510-2810305-1-git-send-email-ast@fb.com>
	<20160421140255.GH3430@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160421140255.GH3430@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Apr 2016 16:02:55 +0200
Peter Zijlstra <peterz@infradead.org> wrote:


> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> 
> David, please take through the net tree as this depends on prior patches
> by Alexei that are already in your tree.

Yes please!

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve
