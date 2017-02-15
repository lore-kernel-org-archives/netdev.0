From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Update proper netdev stats for rx drops
Date: Wed, 15 Feb 2017 12:41:16 -0500 (EST)
Message-ID: <20170215.124116.1461042487398004368.davem@davemloft.net>
References: <1487139325-10588-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, arjun@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35684 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750905AbdBORlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 12:41:18 -0500
In-Reply-To: <1487139325-10588-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Wed, 15 Feb 2017 11:45:25 +0530

> Count buffer group drops or truncates as rx drops rather than
> rx errors in netdev stats.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> Signed-off-by: Arjun V <arjun@chelsio.com>

Applied.
