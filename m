From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] net: qualcomm: rmnet: Add 64 bit stats
 and GRO
Date: Sat, 28 Oct 2017 00:10:44 +0900 (KST)
Message-ID: <20171028.001044.1897184090877384008.davem@davemloft.net>
References: <1509037609-15444-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51180 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932327AbdJ0PKr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 11:10:47 -0400
In-Reply-To: <1509037609-15444-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Thu, 26 Oct 2017 11:06:45 -0600

> This series adds support for 64 bit per cpu stats and GRO
> 
> Patches 1-2 are cleanups of return code and a redundant condition
> Patch 3 adds support for 64 bit per cpu stats
> Patch 4 adds support for GRO using GRO cells
> 
> v1->v2: Since gro_cells_init() could potentially fail, move it from device
> setup to ndo_init() as mentioned by Eric.

Series applied, thank you.
