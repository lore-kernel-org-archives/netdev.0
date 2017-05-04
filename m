From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] forcedeth: remove unnecessary carrier status check
Date: Thu, 04 May 2017 10:58:07 -0400 (EDT)
Message-ID: <20170504.105807.2275033957289769591.davem@davemloft.net>
References: <1493786622-16654-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yanjun.zhu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55548 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751214AbdEDO6J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 10:58:09 -0400
In-Reply-To: <1493786622-16654-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@oracle.com>
Date: Wed,  3 May 2017 00:43:42 -0400

> Since netif_carrier_on() will do nothing if device's
> carrier is already on, so it's unnecessary to do
> carrier status check.
> 
> It's the same for netif_carrier_off().
> 
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>

Applied, thanks.
