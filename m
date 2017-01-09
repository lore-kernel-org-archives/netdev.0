From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: change init_inodecache() return void
Date: Mon, 09 Jan 2017 12:05:42 -0500 (EST)
Message-ID: <20170109.120542.325075389222820162.davem@davemloft.net>
References: <1483780711-5759-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42644 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763025AbdAIRFu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:05:50 -0500
In-Reply-To: <1483780711-5759-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Sat,  7 Jan 2017 17:18:31 +0800

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> sock_init() call it but not check it's return value,
> so change it to void return and add an internal BUG_ON() check.
> 
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Applied.
