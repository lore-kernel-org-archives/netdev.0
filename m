From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: delete original tun_get() and rename
 __tun_get() to tun_get()
Date: Mon, 25 Sep 2017 20:30:27 -0700 (PDT)
Message-ID: <20170925.203027.2104831550007889646.davem@davemloft.net>
References: <1506177412-20280-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964942AbdIZDa2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 23:30:28 -0400
In-Reply-To: <1506177412-20280-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Sat, 23 Sep 2017 22:36:52 +0800

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> it seems no need to keep tun_get() and __tun_get() at same time.
> 
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Applied.
