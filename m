From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Remove redundant code in
 t4_uld_clean_up()
Date: Thu, 16 Feb 2017 14:33:30 -0500 (EST)
Message-ID: <20170216.143330.750567543969568421.davem@davemloft.net>
References: <1487228235-29489-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55892 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932694AbdBPTdi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 14:33:38 -0500
In-Reply-To: <1487228235-29489-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Thu, 16 Feb 2017 12:27:15 +0530

> Remove variable rxq_info and also remove redundant assignment
> to it.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
