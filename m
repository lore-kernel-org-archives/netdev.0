From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] rtnetlink: return the correct error code
Date: Thu, 01 Dec 2016 14:39:03 -0500 (EST)
Message-ID: <20161201.143903.1524429041598350332.davem@davemloft.net>
References: <1480495054-5114-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42514 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753512AbcLATjF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 14:39:05 -0500
In-Reply-To: <1480495054-5114-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Wed, 30 Nov 2016 16:37:34 +0800

> Before this patch, function ndo_dflt_fdb_dump() will always return code
> from uc fdb dump. The reture code of mc fdb dump is lost.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied.
