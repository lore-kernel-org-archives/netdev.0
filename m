From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb3: Check and handle the dma mapping errors
Date: Sun, 29 Oct 2017 11:10:37 +0900 (KST)
Message-ID: <20171029.111037.2086005979992985258.davem@davemloft.net>
References: <1509107901-13842-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com, arjun@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43618 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751216AbdJ2CKm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 22:10:42 -0400
In-Reply-To: <1509107901-13842-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Fri, 27 Oct 2017 18:08:21 +0530

> From: Arjun Vynipadath <arjun@chelsio.com>
> 
> This patch adds checks at approprate places whether *dma_map*() call has
> succeeded or not.
> 
> Original Work by: Santosh Rastapur <santosh@chelsio.com>
> Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
