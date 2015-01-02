From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3][v2] net/fsl: remove reset from xgmac_mdio
Date: Fri, 02 Jan 2015 15:40:12 -0500 (EST)
Message-ID: <20150102.154012.1894046075600347125.davem@davemloft.net>
References: <1419928053-2450-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbbABUkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 15:40:15 -0500
In-Reply-To: <1419928053-2450-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Tue, 30 Dec 2014 16:27:33 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> Since the reset is just clock setting, individual mdio reset is
> not available.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied to net-next.
