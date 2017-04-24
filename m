From: David Miller <davem@davemloft.net>
Subject: Re: [pull request][net 0/7] Mellanox, mlx5 fixes 2017-04-22
Date: Mon, 24 Apr 2017 16:01:43 -0400 (EDT)
Message-ID: <20170424.160143.1233208091847623161.davem@davemloft.net>
References: <20170423100802.27630-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57002 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S977415AbdDXUB4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 16:01:56 -0400
In-Reply-To: <20170423100802.27630-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Sun, 23 Apr 2017 13:07:55 +0300

> This series contains some mlx5 fixes for net.
> 
> For your convenience, the series doesn't introduce any conflict with
> the ongoing net-next pull request.
> 
> Please pull and let me know if there's any problem.

Pulled.

> For -stable:
> ("net/mlx5: E-Switch, Correctly deal with inline mode on ConnectX-5") kernels >= 4.10
> ("net/mlx5e: Fix ETHTOOL_GRXCLSRLALL handling") kernels >= 4.8
> ("net/mlx5e: Fix small packet threshold")       kernels >= 4.7
> ("net/mlx5: Fix driver load bad flow when having fw initializing timeout") kernels >= 4.4

Queued up, thanks.
