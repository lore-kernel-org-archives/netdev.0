From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] Mellanox mlx5 fixes 2017-03-09
Date: Fri, 10 Mar 2017 10:03:43 -0800 (PST)
Message-ID: <20170310.100343.399238422766007828.davem@davemloft.net>
References: <20170310123305.2185-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755430AbdCJSDq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:03:46 -0500
In-Reply-To: <20170310123305.2185-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Fri, 10 Mar 2017 14:33:00 +0200

> This series contains some mlx5 core and ethernet driver fixes.
> 
> For -stable:
> net/mlx5e: remove IEEE/CEE mode check when setting DCBX mode (for kernel >= 4.10)
> net/mlx5e: Avoid wrong identification of rules on deletion (for kernel >= 4.9)
> net/mlx5: Don't save PCI state when PCI error is detected (for kernel >= 4.9)
> net/mlx5: Fix create autogroup prev initializer (for kernel >=4.9)

Series applied, thanks.
