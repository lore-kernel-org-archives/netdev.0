From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/fsl: drop in_be32() & out_be32() in xgmac_mdio
Date: Sun, 25 Jan 2015 23:36:22 -0800 (PST)
Message-ID: <20150125.233622.351973212819119937.davem@davemloft.net>
References: <1421838469-782-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbbAZHgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 02:36:23 -0500
In-Reply-To: <1421838469-782-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Wed, 21 Jan 2015 19:07:49 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> Use ioread32be() & iowrite32be() instead.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied to net-next.
