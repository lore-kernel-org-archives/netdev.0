From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] cxgb4: Support compressed error vector for
 T6
Date: Wed, 04 Jan 2017 14:02:15 -0500 (EST)
Message-ID: <20170104.140215.1572549980786472794.davem@davemloft.net>
References: <1483536860-2672-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, arjun@chelsio.com,
        santosh@chelsio.com, hariprasad@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60100 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753541AbdADTCR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 14:02:17 -0500
In-Reply-To: <1483536860-2672-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Wed,  4 Jan 2017 19:04:20 +0530

> From: Arjun V <arjun@chelsio.com>
> 
> t6fw-1.15.15.0 enabled compressed error vector in cpl_rx_pkt for T6.
> Updating driver to take care of these changes.
> 
> Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
> Signed-off-by: Arjun V <arjun@chelsio.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> ---
> v2: Fixed kbuild errors

Applied, thanks.
