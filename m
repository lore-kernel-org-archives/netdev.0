From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: fix to bring link down after adapter
 crash
Date: Thu, 08 Jun 2017 14:41:47 -0400 (EDT)
Message-ID: <20170608.144147.658139195316875158.davem@davemloft.net>
References: <1496899331-18481-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com,
        rahul.lakkireddy@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdFHSls (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 14:41:48 -0400
In-Reply-To: <1496899331-18481-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Thu,  8 Jun 2017 10:52:11 +0530

> From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> 
> Use PORT_REG for T4 and T5_PORT_REG for > T4 to write to correct
> register to bring down link during shutdown after adapter crash.
> 
> Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied, thanks.
