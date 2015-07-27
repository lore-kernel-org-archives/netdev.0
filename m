From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: fix auto negotiation checking for teranetics
Date: Mon, 27 Jul 2015 01:04:51 -0700 (PDT)
Message-ID: <20150727.010451.2303210475092539484.davem@davemloft.net>
References: <1437737162-32854-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbbG0IEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:04:52 -0400
In-Reply-To: <1437737162-32854-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Fri, 24 Jul 2015 19:26:02 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> When using fiber port, the phy cannot report it's auto negotiation state,
> driver should always report auto negotiation is done when using fiber port.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied.
