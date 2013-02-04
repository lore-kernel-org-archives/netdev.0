From: David Miller <davem@davemloft.net>
Subject: Re: [PATH net-next v1 1/2] net/mlx4_en: Fix error propagation for
 ethtool helper function
Date: Mon, 04 Feb 2013 13:33:11 -0500 (EST)
Message-ID: <20130204.133311.538535640282513665.davem@davemloft.net>
References: <1359982881-10139-1-git-send-email-amirv@mellanox.com>
	<1359982881-10139-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadarh@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44102 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230Ab3BDSdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 13:33:14 -0500
In-Reply-To: <1359982881-10139-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon,  4 Feb 2013 15:01:20 +0200

> From: Hadar Hen Zion <hadarh@mellanox.com>
> 
> Propagate return value of mlx4_en_ethtool_add_mac_rule_by_ipv4 in case of
> failure.
> 
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Applied.
