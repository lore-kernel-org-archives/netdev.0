From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: remove cls_flower idr on failure
Date: Thu, 21 Sep 2017 15:14:54 -0700 (PDT)
Message-ID: <20170921.151454.1109566966050664026.davem@davemloft.net>
References: <20170920161845.28753-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrism@mellanox.com, jiri@mellanox.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59758 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUWO5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 18:14:57 -0400
In-Reply-To: <20170920161845.28753-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 20 Sep 2017 09:18:45 -0700

> Fixes: c15ab236d69d ("net/sched: Change cls_flower to use IDR")
> Cc: Chris Mi <chrism@mellanox.com>
> Cc: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
