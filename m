From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: Fix number of queue sets corssing the limit
Date: Tue, 18 Oct 2016 10:33:01 -0400 (EDT)
Message-ID: <20161018.103301.1520057027715001809.davem@davemloft.net>
References: <1476780685-31363-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linteam@chelsio.com,
        hariprasad@chelsio.com, nirranjan@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934472AbcJROdJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 10:33:09 -0400
In-Reply-To: <1476780685-31363-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Tue, 18 Oct 2016 14:21:25 +0530

> Do not let number of offload queue sets to go more than
> MAX_OFLD_QSETS, which would otherwise crash the driver
> on machines with cores more than MAX_OFLD_QSETS.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied, thank you.
