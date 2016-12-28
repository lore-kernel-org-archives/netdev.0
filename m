From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 00/12] Mellanox 100G mlx5 fixes 28-12-2016
Date: Wed, 28 Dec 2016 14:38:38 -0500 (EST)
Message-ID: <20161228.143838.941881149873154287.davem@davemloft.net>
References: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44400 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751928AbcL1Tik (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 14:38:40 -0500
In-Reply-To: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Wed, 28 Dec 2016 14:58:30 +0200

> Some fixes for mlx5 core and ethernet driver.
> 
> for -stable:
>     net/mlx5: Check FW limitations on log_max_qp before setting it
>     net/mlx5: Cancel recovery work in remove flow
>     net/mlx5: Avoid shadowing numa_node
>     net/mlx5: Mask destination mac value in ethtool steering rules
>     net/mlx5: Prevent setting multicast macs for VFs
>     net/mlx5e: Don't sync netdev state when not registered
>     net/mlx5e: Disable netdev after close

Series applied, and the patches from the list above have been queued up
for -stable.

Thanks!
