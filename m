From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: do not name the pointer to struct
 net_device net
Date: Thu, 24 Jul 2014 23:34:51 -0700 (PDT)
Message-ID: <20140724.233451.1720790778193774922.davem@davemloft.net>
References: <1406156950-8934-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaGYGex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:34:53 -0400
In-Reply-To: <1406156950-8934-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 23 Jul 2014 16:09:10 -0700

> "net" is normally for struct net*, pointer to struct net_device
> should be named to either "dev" or "ndev" etc.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
