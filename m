From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Convert qdisc linked list into a hashtable
Date: Wed, 10 Aug 2016 17:22:33 -0700 (PDT)
Message-ID: <20160810.172233.1177985248903694422.davem@davemloft.net>
References: <alpine.LNX.2.00.1608101049260.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jhs@mojatatu.com, phil@nwl.cc,
	xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jikos@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1608101049260.22028@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jikos@kernel.org>
Date: Wed, 10 Aug 2016 11:00:42 +0200 (CEST)

> This is a respin of the v6 of the original patch [1], split into two-patch 
> series as requested by davem; first patch fixes all symbol conflicts 
> that'd happen once netdevice.h starts to include hashtable.h, the second 
> one performs the actual switch to hashtable.
> 
> I've preserved Cong's Reviewed-by:, as code-wise this series is identical 
> to the original v6 of the patch.
> 
> [1] lkml.kernel.org/r/alpine.LNX.2.00.1608011220580.22028@cbobk.fhfr.pm

Series applied, thank you.
