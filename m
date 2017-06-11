From: David Miller <davem@davemloft.net>
Subject: Re: [pull request][net 0/6] Mellanox mlx5 fixes 2017-06-11
Date: Sun, 11 Jun 2017 16:42:10 -0400 (EDT)
Message-ID: <20170611.164210.726640838112020106.davem@davemloft.net>
References: <20170611140028.12467-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38928 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751794AbdFKUmL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 16:42:11 -0400
In-Reply-To: <20170611140028.12467-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Sun, 11 Jun 2017 17:00:22 +0300

> This series contains some fixes for the mlx5 core and netdev driver.
> 
> Please pull and let me know if there's any problem.

Pulled, thanks.

> For -stable:
> ("net/mlx5e: Added BW check for DIM decision mechanism")              kernels >= 4.9
> ("net/mlx5e: Fix wrong indications in DIM due to counter wraparound") kernels >= 4.9
> ("net/mlx5: Remove several module events out of ethtool stats")       kernels >= 4.10
> ("net/mlx5: Enable 4K UAR only when page size is bigger than 4K")     kernels >= 4.11
> 
> *all patches apply with no issue on their -stable.
> 
> BTW I never asked you if this way of marking patches to -stable is good for you ?
> if you prefer another format please let me know.

It works fine for now, I'll let you know if it causes problems :)
