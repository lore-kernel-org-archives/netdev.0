From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4/cxgb4vf: Assign netdev->dev_port with port ID
Date: Thu, 08 Dec 2016 18:21:25 -0500 (EST)
Message-ID: <20161208.182125.1415127945083752236.davem@davemloft.net>
References: <1481200763-15799-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, arjun@chelsio.com,
        leedom@chelsio.com, hariprasad@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45376 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932964AbcLHXV1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 18:21:27 -0500
In-Reply-To: <1481200763-15799-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Thu,  8 Dec 2016 18:09:23 +0530

> From: Arjun V <arjun@chelsio.com>
> 
> Added missing dev_port assignment in cxgb4vf driver.
> Also made dev_port assignment of cxgb4 in sync with cxgb4vf driver.
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Arjun V <arjun@chelsio.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
