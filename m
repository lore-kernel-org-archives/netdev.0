From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cpsw: check for cpts pointer after its allocation
Date: Mon, 17 Jun 2013 16:26:25 -0700 (PDT)
Message-ID: <20130617.162625.965940742231450907.davem@davemloft.net>
References: <1371490312-27905-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142Ab3FQX00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 19:26:26 -0400
In-Reply-To: <1371490312-27905-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 17 Jun 2013 19:31:52 +0200

> after priv->cpts got allocated then this pointer should check to determine
> if the allocation succeeded or not.
> 
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Applied, thanks.
