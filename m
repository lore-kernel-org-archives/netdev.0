From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix unused variable warning
Date: Fri, 20 Jan 2017 11:16:13 -0500 (EST)
Message-ID: <20170120.111613.1785085164218270615.davem@davemloft.net>
References: <1484903839-5890-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        hariprasad@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60926 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752730AbdATQZs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:25:48 -0500
In-Reply-To: <1484903839-5890-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Fri, 20 Jan 2017 14:47:19 +0530

> Fix unused variable warning when CONFIG_PCI_IOV is not
> defined.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Arnd already submitted a fix for this, and unlike your's his provided
a proper Fixes-by: tag.

Thanks.
