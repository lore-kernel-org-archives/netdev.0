From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_en: Hardware accelerated 802.1ad
 works only on the first port
Date: Wed, 29 Jul 2015 12:22:20 -0700 (PDT)
Message-ID: <20150729.122220.2000858785713042224.davem@davemloft.net>
References: <1438078759-21477-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadarh@mellanox.com, ogerlitz@mellanox.com,
	talal@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33509 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199AbbG2TWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 15:22:21 -0400
In-Reply-To: <1438078759-21477-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 28 Jul 2015 13:19:19 +0300

> Fix mistakenly used, hard coded, port number in get_phv_bit()
> 
> Fixes: 77fc29c ("net/mlx4_core: Preparations for 802.1ad VLAN support")
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied.
