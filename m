From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/fsl: Replace spin_event_timeout() with arch
 independent in xgmac_mdio
Date: Sun, 25 Jan 2015 23:36:27 -0800 (PST)
Message-ID: <20150125.233627.197567112031949626.davem@davemloft.net>
References: <1421838512-826-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444AbbAZHg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 02:36:28 -0500
In-Reply-To: <1421838512-826-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Wed, 21 Jan 2015 19:08:32 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> spin_event_timeout() is PPC dependent, use an arch independent
> equivalent instead.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied to net-next.
