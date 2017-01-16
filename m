From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qed: Replace memset with eth_zero_addr
Date: Mon, 16 Jan 2017 14:58:19 -0500 (EST)
Message-ID: <20170116.145819.115892553691222296.davem@davemloft.net>
References: <1484592698-19747-1-git-send-email-mayhs11saini@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
To: mayhs11saini@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47706 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdAPT6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 14:58:21 -0500
In-Reply-To: <1484592698-19747-1-git-send-email-mayhs11saini@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shyam Saini <mayhs11saini@gmail.com>
Date: Tue, 17 Jan 2017 00:21:38 +0530

> Use eth_zero_addr to assign zero address to the given address array
> instead of memset when the second argument in memset is address
> of zero. Also, it makes the code clearer
> 
> Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>

This patch does not apply cleanly to the net-next tree.

Please state if you don't understand what that means instead of
submitting this patch over and over again against the wrong source
tree.

Thanks.
