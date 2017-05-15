From: David Miller <davem@davemloft.net>
Subject: Re: [pull request][net V2 0/5] Mellanox, mlx5 fixes 2017-05-12
Date: Mon, 15 May 2017 14:38:56 -0400 (EDT)
Message-ID: <20170515.143856.1085319582171965999.davem@davemloft.net>
References: <20170514104311.2081-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932948AbdEOSi6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 14:38:58 -0400
In-Reply-To: <20170514104311.2081-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Sun, 14 May 2017 13:43:06 +0300

> This series contains some mlx5 fixes for net.
> Please pull and let me know if there's any problem.
> 
> For -stable:
> ("net/mlx5e: Fix ethtool pause support and advertise reporting") kernels >= 4.8
> ("net/mlx5e: Use the correct pause values for ethtool advertising") kernels >= 4.8
> 
> v1->v2:
>  Dropped statistics spinlock patch, it needs some extra work.

Pulled and the first two patches queued up for -stable, thanks.
