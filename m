From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: reduce resource allocation in kdump
 kernel
Date: Wed, 17 May 2017 12:03:22 -0400 (EDT)
Message-ID: <20170517.120322.2110613664364177408.davem@davemloft.net>
References: <1494949662-8339-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, indranil@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754679AbdEQQEJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 12:04:09 -0400
In-Reply-To: <1494949662-8339-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Tue, 16 May 2017 21:17:42 +0530

> When is_kdump_kernel() is true, reduce memory footprint of
> cxgb4 by using a single "Queue Set".
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
