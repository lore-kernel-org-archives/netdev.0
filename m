From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tg3: Call tg3_netif_stop() from tg3_stop()
Date: Tue, 06 Nov 2012 19:00:48 -0500 (EST)
Message-ID: <20121106.190048.2206430857624402333.davem@davemloft.net>
References: <1352161590-1586-1-git-send-email-mchan@broadcom.com>
	<1352161590-1586-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027Ab2KGAAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 19:00:49 -0500
In-Reply-To: <1352161590-1586-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 5 Nov 2012 16:26:30 -0800

> From: Nithin Nayak Sujir <nsujir@broadcom.com>
> 
> instead of making separate tg3_napi_disable() and netif_tx_disable() calls.
> 
> Update version to 3.126.
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
