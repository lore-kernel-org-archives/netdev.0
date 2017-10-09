From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Fix mlx4 static checker warnings
Date: Mon, 09 Oct 2017 10:33:22 -0700 (PDT)
Message-ID: <20171009.103322.924440963730306089.davem@davemloft.net>
References: <1507557590-17747-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52714 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdJIRdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:33:23 -0400
In-Reply-To: <1507557590-17747-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Mon,  9 Oct 2017 16:59:47 +0300

> This patchset contains fixes for static checker warnings
> in the mlx4 Core and Eth drivers.
> 
> Patch 1 fixes an actual bug discovered by the checker.
> Patches 2 and 3 fix the warnings without functional changes.
> 
> Series generated against net-next commit:
> c49c777f9c87 qed: Delete redundant check on dcb_app priority

Series applied, thanks.
