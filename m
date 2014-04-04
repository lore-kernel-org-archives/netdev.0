From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc911x: Remove unused local variable
Date: Fri, 04 Apr 2014 10:03:11 -0400 (EDT)
Message-ID: <20140404.100311.667126896632142344.davem@davemloft.net>
References: <1396570583-6564-1-git-send-email-laurent.pinchart@ideasonboard.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: laurent.pinchart@ideasonboard.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbaDDOBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 10:01:36 -0400
In-Reply-To: <1396570583-6564-1-git-send-email-laurent.pinchart@ideasonboard.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Date: Fri,  4 Apr 2014 02:16:23 +0200

> The ioaddr local variable is assigned to but never used in the
> smc911x_rx_dma_irq() function, remove it.
> 
> Signed-off-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>

Applied.
