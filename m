From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/8] Mellanox mlx5 fixes 2017-03-21
Date: Wed, 22 Mar 2017 12:13:48 -0700 (PDT)
Message-ID: <20170322.121348.1362827239428928522.davem@davemloft.net>
References: <20170321135919.25018-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43338 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935995AbdCVTNu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 15:13:50 -0400
In-Reply-To: <20170321135919.25018-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Tue, 21 Mar 2017 15:59:11 +0200

> This series contains some mlx5 core and ethernet driver fixes.

Series applied, thanks.

> For -stable:
> net/mlx5e: Count LRO packets correctly (for kernel >= 4.2)
> net/mlx5e: Count GSO packets correctly (for kernel >= 4.2)
> net/mlx5: Increase number of max QPs in default profile (for kernel >= 4.0)
> net/mlx5e: Avoid supporting udp tunnel port ndo for VF reps (for kernel >= 4.10)
> net/mlx5e: Use the proper UAPI values when offloading TC vlan actions (for kernel >= v4.9)
> net/mlx5: E-Switch, Don't allow changing inline mode when flows are configured (for kernel >= 4.10)
> net/mlx5e: Change the TC offload rule add/del code path to be per NIC or E-Switch (for kernel >= 4.10)
> net/mlx5: Add missing entries for set/query rate limit commands (for kernel >= 4.8)

Ok, queued up.
