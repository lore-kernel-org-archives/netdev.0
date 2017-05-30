From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix netdev_features flag
Date: Tue, 30 May 2017 14:16:45 -0400 (EDT)
Message-ID: <20170530.141645.836072420180061127.davem@davemloft.net>
References: <1496131224-11688-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, arjun@chelsio.com,
        swise@opengridcomputing.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54374 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751209AbdE3SQr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 14:16:47 -0400
In-Reply-To: <1496131224-11688-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Tue, 30 May 2017 13:30:24 +0530

> From: Arjun Vynipadath <arjun@chelsio.com>
> 
> GRO is not supported by Chelsio HW when rx_csum is disabled.
> Update the netdev features flag when rx_csum is modified.
> 
> Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
