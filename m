From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: add interrupt support for aquantia phy
Date: Sun, 23 Aug 2015 23:14:41 -0700 (PDT)
Message-ID: <20150823.231441.842232304669266968.davem@davemloft.net>
References: <1440142169-37100-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbbHXGOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 02:14:42 -0400
In-Reply-To: <1440142169-37100-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Fri, 21 Aug 2015 15:29:29 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> By implementing config_intr & ack_interrupt, now the phy can support
> link connect/disconnect interrupt.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied to net-next, thanks.
