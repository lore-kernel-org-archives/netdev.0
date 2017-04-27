From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net: remove unnecessary carrier status check
Date: Thu, 27 Apr 2017 16:31:42 -0400 (EDT)
Message-ID: <20170427.163142.1805901844340899570.davem@davemloft.net>
References: <1493200178-6413-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45544 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968874AbdD0Ubp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 16:31:45 -0400
In-Reply-To: <1493200178-6413-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Wed, 26 Apr 2017 17:49:38 +0800

> Since netif_carrier_on() will do nothing if device's carrier is already
> on, so it's unnecessary to do carrier status check.
> 
> It's the same for netif_carrier_off().
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, thank you.
