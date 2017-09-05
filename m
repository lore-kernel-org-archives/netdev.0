From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Ignore MPS_TX_INT_CAUSE[Bubble] for T6
Date: Tue, 05 Sep 2017 14:28:38 -0700 (PDT)
Message-ID: <20170905.142838.1403047581242587899.davem@davemloft.net>
References: <1504504534-22115-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com, leedom@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753490AbdIEV2j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 17:28:39 -0400
In-Reply-To: <1504504534-22115-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Mon,  4 Sep 2017 11:25:34 +0530

> MPS_TX_INT_CAUSE[Bubble] is a normal condition for T6, hence
> ignore this interrupt for T6.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied.
