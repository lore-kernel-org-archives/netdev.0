From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix warning of versioncheck
Date: Thu, 07 Jul 2011 00:26:39 -0700 (PDT)
Message-ID: <20110707.002639.423036090394453193.davem@davemloft.net>
References: <4E152325.4050202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com,
	sjur.brandeland@stericsson.com
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952Ab1GGH0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 03:26:51 -0400
In-Reply-To: <4E152325.4050202@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Thu, 07 Jul 2011 11:08:21 +0800

> 
> net-next-2.6/drivers/net/bnx2x/bnx2x_sp.c: 19 linux/version.h not needed.
> net-next-2.6/drivers/net/caif/caif_hsi.c: 9 linux/version.h not needed.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied.
