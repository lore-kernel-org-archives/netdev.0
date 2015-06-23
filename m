From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/phy: Add support for Realtek RTL8211F
Date: Tue, 23 Jun 2015 01:06:39 -0700 (PDT)
Message-ID: <20150623.010639.431315316588044220.davem@davemloft.net>
References: <1434616967-38930-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: Shengzhou.Liu@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbbFWHyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 03:54:51 -0400
In-Reply-To: <1434616967-38930-1-git-send-email-Shengzhou.Liu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Date: Thu, 18 Jun 2015 16:42:47 +0800

> RTL8211F has different register definitions from RTL8211E.
> Specially it needs to enable TXDLY in case of RGMII.
> 
> Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>

Applied, thanks.
