From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: move procfs code to net/core/net-procfs.c
Date: Tue, 19 Feb 2013 00:54:39 -0500 (EST)
Message-ID: <20130219.005439.1803797446945089727.davem@davemloft.net>
References: <1361251233-25914-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756851Ab3BSFyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:54:41 -0500
In-Reply-To: <1361251233-25914-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 19 Feb 2013 13:20:33 +0800

> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> Similar to net/core/net-sysfs.c, group procfs code to
> a single unit.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
