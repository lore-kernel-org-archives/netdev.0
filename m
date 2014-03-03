From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/9] net/mlx4: Mellanox driver update
 27-02-2014
Date: Sun, 02 Mar 2014 20:04:34 -0500 (EST)
Message-ID: <20140302.200434.597366269924527364.davem@davemloft.net>
References: <1393748705-1685-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbaCCBEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 20:04:38 -0500
In-Reply-To: <1393748705-1685-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun,  2 Mar 2014 10:24:56 +0200

> This patchset contains some fixes for small trivial bugs, and
> compilation/syntactic parsers warnings
> 
> Patchset was applied and tested over commit 750f679 "Merge branch '6lowpan'"
> 
> Changes from V1:
> -patch 5/9:  Replace mlx4_en_mac_to_u64() with mlx4_mac_to_u64()
>   - Remove unnecessary define of ETH_ALEN
> 
> Changes from V0:
> -patch 3/9:  net/mlx4_en: Pad ethernet packets smaller than 17 bytes
>   - Make condition more efficient
>   - Didn't use canonical function to pad buffer since using bounce buffer

Series applied, thanks.
