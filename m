From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] net: sh_eth: modify a condition of
 ioremap for TSU
Date: Thu, 16 Feb 2012 17:08:58 -0500 (EST)
Message-ID: <20120216.170858.1937108085697213343.davem@davemloft.net>
References: <4F3C7E15.7020504@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754620Ab2BPWJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 17:09:02 -0500
In-Reply-To: <4F3C7E15.7020504@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Thu, 16 Feb 2012 12:55:01 +0900

> If the controller has TSU, the each channel needs TSU registers.
> This patch also fixes the iounmap condition in the sh_eth_drv_remove().
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
