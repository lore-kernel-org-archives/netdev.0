From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] mlx4 misc fixes
Date: Wed, 02 Aug 2017 10:44:30 -0700 (PDT)
Message-ID: <20170802.104430.245854578735225346.davem@davemloft.net>
References: <1501595026-32368-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54986 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751891AbdHBRob (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 13:44:31 -0400
In-Reply-To: <1501595026-32368-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Tue,  1 Aug 2017 16:43:42 +0300

> This patchset contains misc bug fixes from the team
> to the mlx4 Core and Eth drivers.
> 
> Patch 1 by Inbar fixes a wrong ethtool indication for Wake-on-LAN.
> The other 3 patches by Jack add a missing capability description,
> and fixes the off-by-1 misalignment for the following capabilities
> descriptions.
> 
> Series generated against net commit:
> cc75f8514db6 samples/bpf: fix bpf tunnel cleanup

Series applied, thanks!
