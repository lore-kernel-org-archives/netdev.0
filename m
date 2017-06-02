From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: fix incorrect cim_la output for T6
Date: Fri, 02 Jun 2017 14:07:34 -0400 (EDT)
Message-ID: <20170602.140734.1352473112563920786.davem@davemloft.net>
References: <1496238021-23996-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, indranil@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45934 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751170AbdFBSHg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:07:36 -0400
In-Reply-To: <1496238021-23996-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Wed, 31 May 2017 19:10:21 +0530

> take care of UpDbgLaRdPtr[0-3] restriction for T6.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> ---
> v2:
> - not using loop to increment UPDBGLARDPTR

Applied, thank you.
