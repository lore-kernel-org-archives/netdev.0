From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed*: Add support for QL41xxx adapters
Date: Tue, 14 Mar 2017 11:43:40 -0700 (PDT)
Message-ID: <20170314.114340.1999131518365119188.davem@davemloft.net>
References: <1489501434-23917-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tomer.Tayar@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49580 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbdCNSnm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 14:43:42 -0400
In-Reply-To: <1489501434-23917-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Tue, 14 Mar 2017 16:23:54 +0200

> This adds the necessary infrastructure changes for initializing
> and working with the new series of QL41xxx adapaters.
> 
> It also adds 2 new PCI device-IDs to qede:
>   - 0x8070 for QL41xxx PFs
>   - 0x8090 for VFs spawning from QL41xxx PFs
> 
> Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied, thanks.
