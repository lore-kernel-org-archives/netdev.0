From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix tids count for ipv6 offload
 connection
Date: Wed, 07 Jun 2017 15:15:24 -0400 (EDT)
Message-ID: <20170607.151524.280614357618965059.davem@davemloft.net>
References: <1496828091-13947-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, swise@opengridcomputing.com,
        dledford@redhat.com, linux-rdma@vger.kernel.org,
        jejb@linux.vnet.ibm.com, linux-scsi@vger.kernel.org,
        nab@linux-iscsi.org, target-devel@vger.kernel.org,
        rizwana@chelsio.com, varun@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34246 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752444AbdFGTPb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:15:31 -0400
In-Reply-To: <1496828091-13947-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Wed,  7 Jun 2017 15:04:51 +0530

> the adapter consumes two tids for every ipv6 offload
> connection be it active or passive, calculate tid usage
> count accordingly.
> 
> Also change the signatures of relevant functions to get
> the address family.
> 
> Signed-off-by: Rizwan Ansari <rizwana@chelsio.com>
> Signed-off-by: Varun Prakash <varun@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied, thanks.
