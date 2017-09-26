From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: do DCB state reset in couple of places
Date: Mon, 25 Sep 2017 20:28:40 -0700 (PDT)
Message-ID: <20170925.202840.2232367544464064408.davem@davemloft.net>
References: <1506163048-17544-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com, leedom@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40476 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933685AbdIZD2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 23:28:40 -0400
In-Reply-To: <1506163048-17544-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Sat, 23 Sep 2017 16:07:28 +0530

> reset the driver's DCB state in couple of places
> where it was missing.
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
