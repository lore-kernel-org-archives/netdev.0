From: David Miller <davem@davemloft.net>
Subject: Re: [pull request][net 0/8] Mellanox, mlx5 fixes 2017-05-23
Date: Wed, 24 May 2017 15:45:24 -0400 (EDT)
Message-ID: <20170524.154524.40230466601275362.davem@davemloft.net>
References: <20170523141610.27833-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934566AbdEXTpZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 15:45:25 -0400
In-Reply-To: <20170523141610.27833-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Tue, 23 May 2017 17:16:02 +0300

> This series contains some fixes for the mlx5 driver and one small patch that
> adds csum actions accessors in include/net/tc_act/tc_csum.h needed by some of
> mlx5 fixes patches.
> 
> Details are below.
> 
> Please pull and let me know if there's any problem.
> 
> Note: This series doesn't introduce any merge conflict with the ongoing mlx5
> for-next submission.
> 
> For -stable kernels >= 4.7:
> ("net/mlx5: Avoid using pending command interface slots")
> ("net/mlx5: Tolerate irq_set_affinity_hint() failures")

Pulled and queued up for -stable, thanks.
