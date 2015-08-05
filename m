From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 0/4] bpf: Introduce the new ability of eBPF programs
 to access hardware PMU counter
Date: Wed, 5 Aug 2015 12:06:48 +0200
Message-ID: <20150805100648.GA25159@twins.programming.kicks-ass.net>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@plumgrid.com, davem@davemloft.net, acme@kernel.org,
	mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Please split out the core perf API stuff into separate patches.
