From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 3/3] net/mlx4_en: Set number of rx/tx
 channels using ethtool
Date: Fri, 30 Nov 2012 12:16:39 -0500 (EST)
Message-ID: <20121130.121639.619094396601908341.davem@davemloft.net>
References: <1354216903-830-1-git-send-email-amirv@mellanox.com>
	<1354216903-830-4-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, oren@mellanox.com, netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab2K3RQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 12:16:41 -0500
In-Reply-To: <1354216903-830-4-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 29 Nov 2012 21:21:43 +0200

> +static void mlx4_en_get_channels(struct net_device *dev,
> +		struct ethtool_channels *channel)

This is not formatted correctly, the argument on the second line
must line up with the first column after the openning "(" on the
previous line.
