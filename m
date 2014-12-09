From: David Miller <davem@davemloft.net>
Subject: Re: [net_test_tools] udpflood: Add IPv6 support
Date: Tue, 09 Dec 2014 13:05:03 -0500 (EST)
Message-ID: <20141209.130503.1276165663263932336.davem@davemloft.net>
References: <1413837765-5446-1-git-send-email-kafai@fb.com>
	<1417545706-31249-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbaLISFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:05:21 -0500
In-Reply-To: <1417545706-31249-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 2 Dec 2014 10:41:46 -0800

> This patch:
> 1. Add IPv6 support
> 2. Print timing for every 65536 fib insert operations to observe
>    the gc effect (mostly for IPv6 fib).

Applied, thanks.
