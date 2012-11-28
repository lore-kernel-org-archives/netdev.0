From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: QFQ Plus: fair-queueing service at DRR cost
Date: Wed, 28 Nov 2012 11:20:01 -0500 (EST)
Message-ID: <20121128.112001.1723079532431419311.davem@davemloft.net>
References: <20121123210319.GA15775@paolo-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: paolo.valente@unimore.it
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121123210319.GA15775@paolo-ThinkPad-W520>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paolo Valente <paolo.valente@unimore.it>
Date: Fri, 23 Nov 2012 22:03:19 +0100

> This patch turns QFQ into QFQ+, a variant of QFQ that provides the
> following two benefits: 1) QFQ+ is faster than QFQ, 2) differently
> from QFQ, QFQ+ correctly schedules also non-leaves classes in a
> hierarchical setting. A detailed description of QFQ+, plus a
> performance comparison with DRR and QFQ, can be found in [1].
> 
> [1] P. Valente, "Reducing the Execution Time of Fair-Queueing Schedulers"
> http://algo.ing.unimo.it/people/paolo/agg-sched/agg-sched.pdf
> 
> Signed-off-by: Paolo Valente <paolo.valente@unimore.it>

Applied, thanks.
