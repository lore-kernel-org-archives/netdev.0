From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] mlx4_en dynamic TC tx queues
Date: Thu, 29 Jun 2017 15:57:15 -0400 (EDT)
Message-ID: <20170629.155715.1789266355612066226.davem@davemloft.net>
References: <1498734477-26111-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, inbark@mellanox.com,
        tarick@google.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45408 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751827AbdF2T5R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 15:57:17 -0400
In-Reply-To: <1498734477-26111-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu, 29 Jun 2017 14:07:55 +0300

> This patchset from Inbar aligns the number of TX queues
> to the actual need, according to the TC configuration.
> 
> Series generated against net-next commit:
> 2ee87db3a287 Merge branch 'nfp-get_phys_port_name-for-representors-and-SR-IOV-reorder'

Series applied to net-next, thanks.
