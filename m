From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] macvlan: code refine to check data before using
Date: Wed, 20 Sep 2017 13:47:06 -0700 (PDT)
Message-ID: <20170920.134706.1045593398254054043.davem@davemloft.net>
References: <1505866343-14135-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fgao@ikuai8.com, vyasevic@redhat.com, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37032 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdITUrH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 16:47:07 -0400
In-Reply-To: <1505866343-14135-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Wed, 20 Sep 2017 08:12:23 +0800

> This patch checks data first at one place, return if it's null.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Looks good, applied, thanks.
