From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: davicnci_cpdma: check dma map error
Date: Mon, 24 Jun 2013 00:07:47 -0700 (PDT)
Message-ID: <20130624.000747.440345641126322148.davem@davemloft.net>
References: <1371740325-14560-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473Ab3FXHHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 03:07:48 -0400
In-Reply-To: <1371740325-14560-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 20 Jun 2013 16:58:45 +0200

> Since the DMA mapping may fail the caller should check the return value.
> 
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Applied.
