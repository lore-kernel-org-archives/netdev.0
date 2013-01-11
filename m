From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: fib: fix a comment.
Date: Fri, 11 Jan 2013 15:59:11 -0800 (PST)
Message-ID: <20130111.155911.1462784728703281282.davem@davemloft.net>
References: <1357934360-17986-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754255Ab3AKX7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 18:59:14 -0500
In-Reply-To: <1357934360-17986-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Fri, 11 Jan 2013 21:59:20 +0200

> In fib_frontend.c, there is a confusing comment; NETLINK_CB(skb).portid does not 
> refer to a pid of sending process, but rather to a netlink portid.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.
