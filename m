From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/sched/: remove unused exports
Date: Thu, 30 Nov 2006 19:51:00 -0800 (PST)
Message-ID: <20061130.195100.102614532.davem@davemloft.net>
References: <20061126062931.GL15364@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41413
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1758543AbWLADu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 22:50:58 -0500
To: bunk@stusta.de
In-Reply-To: <20061126062931.GL15364@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 26 Nov 2006 07:29:31 +0100

> This patch removes the following unused EXPORT_SYMBOL's:
> - sch_api.c: qdisc_lookup
> - sch_generic.c: __netdev_watchdog_up
> - sch_generic.c: noop_qdisc_ops
> - sch_generic.c: qdisc_alloc
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
