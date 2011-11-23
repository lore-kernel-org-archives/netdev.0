From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix a bug in ndisc_send_redirect
Date: Wed, 23 Nov 2011 03:52:10 -0500 (EST)
Message-ID: <20111123.035210.1727083870458730083.davem@davemloft.net>
References: <4ECC901D.5070905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270Ab1KWIwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 03:52:20 -0500
In-Reply-To: <4ECC901D.5070905@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Wed, 23 Nov 2011 14:18:05 +0800

> Release skb when transmit rate limit _not_ allow
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Applied, thank you.
