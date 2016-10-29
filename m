From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Fix error handling in alloc_uld_rxqs().
Date: Sat, 29 Oct 2016 14:57:03 -0400 (EDT)
Message-ID: <20161029.145703.1725700852324272916.davem@davemloft.net>
References: <1477468598-11296-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com,
        nirranjan@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51772 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbcJ2S5F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 14:57:05 -0400
In-Reply-To: <1477468598-11296-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Wed, 26 Oct 2016 13:26:38 +0530

> Fix to release resources properly in error handling path of
> alloc_uld_rxqs(), This patch also removes unwanted arguments
> and avoids calling the same function twice.
> 
> Fixes: 94cdb8bb993a (cxgb4: Add support for dynamic allocation
>        of resources for ULD
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
