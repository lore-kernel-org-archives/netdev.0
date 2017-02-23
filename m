From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V3 0/5] mlx4 misc fixes
Date: Thu, 23 Feb 2017 10:58:23 -0500 (EST)
Message-ID: <20170223.105823.206533399303723207.davem@davemloft.net>
References: <1487844165-9934-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, yotamg@mellanox.com,
        decui@microsoft.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42566 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbdBWP60 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 10:58:26 -0500
In-Reply-To: <1487844165-9934-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu, 23 Feb 2017 12:02:40 +0200

> This patchset contains misc bug fixes from Eric Dumazet and our team
> to the mlx4 Core and Eth drivers.
> 
> Series generated against net commit:
> eee2faabc63d tcp: account for ts offset only if tsecr not zero
 ...
> v3:
> * Rebased, conflict solved.
> 
> v2:
> * Added Eric's fix (patch 5/5).

Series applied, thanks.
