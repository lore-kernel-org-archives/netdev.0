From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] mlx5 tx timeout watchdog fixes
Date: Wed, 13 Jul 2016 11:38:31 -0700 (PDT)
Message-ID: <20160713.113831.1005946278876914442.davem@davemloft.net>
References: <1468357620-27831-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbcGMSi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 14:38:56 -0400
In-Reply-To: <1468357620-27831-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Wed, 13 Jul 2016 00:06:58 +0300

> This patch set provides two trivial fixes for the tx timeout series lately 
> applied into net 4.7.
> 
> From Daniel, detect stuck queues due to BQL
> From Mohamad, fix tx timeout watchdog false alarm
> 
> Hopefully those two fixes will make it to -stable, assuming 
> 3947ca185999 ('net/mlx5e: Implement ndo_tx_timeout callback') was also backported to -stable.

Series applied.
