From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 0/2] ethtool, net/mlx4_en: RSS hash
 function selection
Date: Mon, 08 Dec 2014 21:07:50 -0500 (EST)
Message-ID: <20141208.210750.1086581659013409504.davem@davemloft.net>
References: <1417536731-11211-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	eyalpe@mellanox.com, yevgenyp@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59338 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbaLICHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 21:07:53 -0500
In-Reply-To: <1417536731-11211-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue,  2 Dec 2014 18:12:09 +0200

> This patchset by Eyal adds support in set/get of RSS hash function. Current
> supported functions are Toeplitz and XOR. The API is design to enable adding
> new hash functions without breaking backward compatibility.
> Userspace patch will be sent after API is available in kernel.
> 
> The patchset was applied and tested over commit cd4c910 ("netpoll: delete
> defconfig references to obsolete NETPOLL_TRAP")

Series applied, thanks.
