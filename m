From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ks8851: convert to threaded IRQ
Date: Tue, 29 Jan 2013 13:32:22 -0500 (EST)
Message-ID: <20130129.133222.794213575131581984.davem@davemloft.net>
References: <20130128.223157.1855971357181002973.davem@davemloft.net>
	<1359443790-8562-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sboyd@codeaurora.org, mjr@cs.wisc.edu, netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab3A2Sc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 13:32:26 -0500
In-Reply-To: <1359443790-8562-1-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felipe Balbi <balbi@ti.com>
Date: Tue, 29 Jan 2013 09:16:30 +0200

> just as it should have been. It also helps
> removing the, now unnecessary, workqueue.
> 
> Signed-off-by: Felipe Balbi <balbi@ti.com>

Applied.
