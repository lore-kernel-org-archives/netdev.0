From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: fix memory leak in init_one()
Date: Fri, 09 Jun 2017 15:53:22 -0400 (EDT)
Message-ID: <20170609.155322.2086436514372975662.davem@davemloft.net>
References: <1497016584-12034-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38420 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751673AbdFITxY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:53:24 -0400
In-Reply-To: <1497016584-12034-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Fri,  9 Jun 2017 19:26:24 +0530

> Free up mbox_log allocated for PF0 to PF3.
> 
> Fixes: 7829451c695e ("cxgb4: Add control net_device for configuring PCIe VF")
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied, thank you.
