From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] Mellanox 100G mlx5e Ethernet extensions
Date: Mon, 27 Jun 2016 04:11:12 -0400 (EDT)
Message-ID: <20160627.041112.56525486705175397.davem@davemloft.net>
References: <1466613197-28726-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbcF0ILj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 04:11:39 -0400
In-Reply-To: <1466613197-28726-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Wed, 22 Jun 2016 19:33:08 +0300

> This series includes multiple features extensions for mlx5 Ethernet netdevice driver.
> Namely, TX Rate limiting, RX interrupt moderation, ethtool settings.
> 
> TX Rate limiting:
> 	- ConnectX-4 rate limiting infrastructure
> 	- Set max rate NDO support
> 
> RX interrupt moderation:
> 	- CQE based coalescing option (controlled via priv flags)
> 	- Adaptive RX coalescing
> 
> ethtool settings:
> 	- priv flags callbacks
> 	- Support new ksettings API
> 	- Add 50G missing link mode
> 	- Support auto negotiation on/off
> 
> Applied on top: 0e9390ebf1fe ("Merge branch 'mlxsw-next'")

Series applied, thanks.
