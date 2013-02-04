From: David Miller <davem@davemloft.net>
Subject: Re: [PATH net-next v1 2/2] net/mlx4_en: Fix compilation error when
 CONFIG_INET isn't defined
Date: Mon, 04 Feb 2013 13:33:17 -0500 (EST)
Message-ID: <20130204.133317.1759959311840833943.davem@davemloft.net>
References: <1359982881-10139-1-git-send-email-amirv@mellanox.com>
	<1359982881-10139-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadarh@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975Ab3BDSdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 13:33:22 -0500
In-Reply-To: <1359982881-10139-3-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon,  4 Feb 2013 15:01:21 +0200

> From: Hadar Hen Zion <hadarh@mellanox.com>
> 
> ip_eth_mc_map function can't be used when CONFIG_INET isn't defined.
> Fixed compilation error by adding CONFIG_INET define check before using the
> function.
> 
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Applied.
