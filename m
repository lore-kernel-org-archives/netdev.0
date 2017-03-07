From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] decnet: Use TCP nagle macro instead of
 literal number in decnet
Date: Tue, 07 Mar 2017 14:09:00 -0800 (PST)
Message-ID: <20170307.140900.1086434081286500280.davem@davemloft.net>
References: <1488636628-14768-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37764 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756426AbdCGWJB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 17:09:01 -0500
In-Reply-To: <1488636628-14768-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Sat,  4 Mar 2017 22:10:28 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> Use existing TCP nagle macro TCP_NAGLE_OFF and TCP_NAGLE_CORK instead
> of the literal number 1 and 2 in the current decnet codes.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
