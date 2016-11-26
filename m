From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] neigh: fix the loop index error in neigh dump
Date: Fri, 25 Nov 2016 20:17:03 -0500 (EST)
Message-ID: <20161125.201703.1849738894862872332.davem@davemloft.net>
References: <1479965109-14607-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58116 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbcKZBRG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 20:17:06 -0500
In-Reply-To: <1479965109-14607-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Thu, 24 Nov 2016 13:25:09 +0800

> Loop index in neigh dump function is not updated correctly under some
> circumstances, this patch will fix it.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

If this bug is also in the 'net' tree you should target this patch
there.

Also, you must provide an appropriate "Fixes: " tag identifying
the commit which introduced this bug.
