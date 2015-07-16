From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: sch_qfq: remove unused member of struct
 qfq_sched
Date: Wed, 15 Jul 2015 17:21:58 -0700 (PDT)
Message-ID: <20150715.172158.1153564265452027383.davem@davemloft.net>
References: <1436825525-13506-1-git-send-email-parri.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, paolo.valente@unimore.it, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: parri.andrea@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436825525-13506-1-git-send-email-parri.andrea@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrea Parri <parri.andrea@gmail.com>
Date: Tue, 14 Jul 2015 00:12:05 +0200

> The member (u32) "num_active_agg" of struct qfq_sched has been unused
> since its introduction in 462dbc9101acd38e92eda93c0726857517a24bbd
> "pkt_sched: QFQ Plus: fair-queueing service at DRR cost" and (AFAICT)
> there is no active plan to use it; this removes the member.
> 
> Signed-off-by: Andrea Parri <parri.andrea@gmail.com>
> Acked-by: Paolo Valente <paolo.valente@unimore.it>

Applied, thanks.
