From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hip04: Remove superfluous ether_setup after
 alloc_etherdev
Date: Mon, 17 Oct 2016 10:32:49 -0400 (EDT)
Message-ID: <20161017.103249.169301846253853366.davem@davemloft.net>
References: <20161017072204.19777-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55920 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932614AbcJQOcv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:32:51 -0400
In-Reply-To: <20161017072204.19777-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon, 17 Oct 2016 09:22:04 +0200

> There is no need to call ether_setup after alloc_ethdev since it was
> already called there.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied to net-next, thanks.
