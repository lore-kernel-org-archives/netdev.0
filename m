From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: save tid while creating server filter
Date: Thu, 13 Apr 2017 12:38:15 -0400 (EDT)
Message-ID: <20170413.123815.1136759076525489427.davem@davemloft.net>
References: <1491839778-8506-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, rajur@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32970 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754497AbdDMQiR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 12:38:17 -0400
In-Reply-To: <1491839778-8506-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Mon, 10 Apr 2017 21:26:18 +0530

> Save the filter tid while creating the server filter, which is used
> later to retrieve the corresponding filter instance while handling
> the filter reply.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
