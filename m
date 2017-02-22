From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2 0/5] mlx4 misc fixes
Date: Wed, 22 Feb 2017 16:47:21 -0500 (EST)
Message-ID: <20170222.164721.147147884837876595.davem@davemloft.net>
References: <1487780729-8798-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, yotamg@mellanox.com,
        decui@microsoft.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933452AbdBVVrX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 16:47:23 -0500
In-Reply-To: <1487780729-8798-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Wed, 22 Feb 2017 18:25:24 +0200

> This patchset contains misc bug fixes from Eric Dumazet and our team
> to the mlx4 Core and Eth drivers.
> 
> Series generated against net commit:
> 00ea1ceebe0d ipv6: release dst on error in ip6_dst_lookup_tail
> 
> Thanks,
> Tariq.
> 
> v2:
> * Added Eric's fix (patch 5/5).

This doesn't apply cleanly to the net tree, please respin.

Thanks.
