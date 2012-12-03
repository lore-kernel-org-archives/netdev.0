From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/3] net/mlx4_en: Set number of rx/tx
 channels using ethtool
Date: Sun, 02 Dec 2012 20:23:29 -0500 (EST)
Message-ID: <20121202.202329.924195508854006256.davem@davemloft.net>
References: <1354456163-10497-1-git-send-email-amirv@mellanox.com>
	<1354456163-10497-4-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, ogerlitz@mellanox.com,
	oren@mellanox.com, netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab2LCBXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 20:23:31 -0500
In-Reply-To: <1354456163-10497-4-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun,  2 Dec 2012 15:49:23 +0200

> Add support to changing number of rx/tx channels using
> ethtool ('ethtool -[lL]'). Where the number of tx channels specified in ethtool
> is the number of rings per user priority - not total number of tx rings.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied.
