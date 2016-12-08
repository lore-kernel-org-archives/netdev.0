From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/1] driver: ipvlan: Unlink the upper dev when
 ipvlan_link_new failed
Date: Thu, 08 Dec 2016 14:30:29 -0500 (EST)
Message-ID: <20161208.143029.1097078029796520755.davem@davemloft.net>
References: <1481167018-559-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37412 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751143AbcLHTac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:30:32 -0500
In-Reply-To: <1481167018-559-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Thu,  8 Dec 2016 11:16:58 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> When netdev_upper_dev_unlink failed in ipvlan_link_new, need to
> unlink the ipvlan dev with upper dev.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
