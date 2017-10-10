From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] mlx4_en num of rings
Date: Tue, 10 Oct 2017 13:11:42 -0700 (PDT)
Message-ID: <20171010.131142.1443108821167866578.davem@davemloft.net>
References: <1507627715-25487-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53420 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934806AbdJJULn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 16:11:43 -0400
In-Reply-To: <1507627715-25487-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Tue, 10 Oct 2017 12:28:32 +0300

> This patchset from Inbar contains changes to rings control
> to the mlx4 Eth driver.
> 
> Patches 1 and 2 limit the number of rings to the number of CPUs.
> Patch 3 removes a limitation in logic of default number of RX rings.
> 
> Series generated against net-next commit:
> 812b5ca7d376 Add a driver for Renesas uPD60620 and uPD60620A PHYs

Series applied, thanks Tariq.
