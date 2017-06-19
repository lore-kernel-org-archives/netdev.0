From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: fix a NULL dereference
Date: Mon, 19 Jun 2017 00:02:41 -0400 (EDT)
Message-ID: <20170619.000241.140276409473549816.davem@davemloft.net>
References: <1497607569-7273-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdFSECn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 00:02:43 -0400
In-Reply-To: <1497607569-7273-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Fri, 16 Jun 2017 15:36:09 +0530

> Avoid NULL dereference in setup_sge_queues() when the adapter is
> in non offload mode.
> 
> Fixes: 0fbc81b3ad51 ('chcr/cxgb4i/cxgbit/RDMA/cxgb4: Allocate resources dynamically for all cxgb4 ULD's')
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
