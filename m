From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] fjes: remove duplicate set of flag IFF_BROADCAST
Date: Tue, 13 Jun 2017 13:55:04 -0400 (EDT)
Message-ID: <20170613.135504.254441343790339094.davem@davemloft.net>
References: <1497358189-3342-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46174 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752615AbdFMRzG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 13:55:06 -0400
In-Reply-To: <1497358189-3342-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue, 13 Jun 2017 20:49:49 +0800

> Remove unnecessary set of flag IFF_BROADCAST, since ether_setup
> already does this.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied with commit log message fixed, thanks.
