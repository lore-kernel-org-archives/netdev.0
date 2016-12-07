From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] nlmon: use core MTU range checking in nlmon driver
Date: Wed, 07 Dec 2016 13:30:07 -0500 (EST)
Message-ID: <20161207.133007.432459376619203666.davem@davemloft.net>
References: <1481102765-12021-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752121AbcLGSaI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 13:30:08 -0500
In-Reply-To: <1481102765-12021-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Wed,  7 Dec 2016 17:26:05 +0800

> Since commit 61e84623ace3 ("net: centralize net_device min/max MTU checking"),
> mtu range is checked at dev_set_mtu().
> 
> This patch adds min_mtu for nlmon device and remove unnecessary
> ndo_change_mtu() function.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied.
