From: David Miller <davem@davemloft.net>
Subject: Re: [pull request][net 0/7] Mellanox, mlx5 fixes 2017-07-09
Date: Sun, 09 Jul 2017 16:08:24 +0100 (WEST)
Message-ID: <20170709.160824.1946848940963297705.davem@davemloft.net>
References: <20170709124917.12852-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60400 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbdGIPI3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 11:08:29 -0400
In-Reply-To: <20170709124917.12852-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Sun,  9 Jul 2017 15:49:10 +0300

> This series includes fixes to mlx5 driver:
>   - Compilation warnings and issues introduced on v4.12
>   - Add Makefile to each mlx5 subdir to allow individual file compilation
>   - Initialize CEE's getpermhwaddr address buffer to 0xff
> 
> Please pull and let me know if there's any problem.

Pulled, thanks.

> For -stable:
>  ("net/mlx5e: Initialize CEE's getpermhwaddr address buffer to 0xff") Kernels >= 4.10

Queued up for -stable.
