From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 4/4] IrDA: Switching to a workqueue for the SIR work
Date: Tue, 09 May 2006 15:27:17 -0700 (PDT)
Message-ID: <20060509.152717.72598970.davem@davemloft.net>
References: <20060508212410.GE20933@irie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, irda-users@lists.sourceforge.net,
	netdev@vger.kernel.org, hch@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32401
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751248AbWEIW1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 18:27:45 -0400
To: samuel.ortiz@nokia.com
In-Reply-To: <20060508212410.GE20933@irie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel.ortiz@nokia.com>
Date: Tue, 9 May 2006 00:24:10 +0300

> Since sir_kthread.c pretty much duplicates the workqueue functionality,
> we'd better switch.
> The SIR fsm has been merged into sir_dev.c and thus sir_kthread.c is
> deleted.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Samuel Ortiz <samuel.ortiz@nokia.com>

Applied, thanks.
