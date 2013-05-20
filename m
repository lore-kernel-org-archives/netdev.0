From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] sock_diag: notify packet socket
 creation/deletion
Date: Sun, 19 May 2013 23:29:25 -0700 (PDT)
Message-ID: <20130519.232925.1972249319855411715.davem@davemloft.net>
References: <1366818756-4234-5-git-send-email-nicolas.dichtel@6wind.com>
	<1368800738-4364-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab3ETG3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 02:29:25 -0400
In-Reply-To: <1368800738-4364-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 17 May 2013 16:25:38 +0200

> With this patch, a netlink message is sent each time a packet socket
> is created or deleted.  The framework is generic, so it's easy to
> add the notification for other kind of sockets.
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Just curious what you want to use this for.
