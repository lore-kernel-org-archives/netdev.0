From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove prune parameter for
 fib6_clean_all
Date: Thu, 02 Jan 2014 03:30:58 -0500 (EST)
Message-ID: <20140102.033058.1338542354904693822.davem@davemloft.net>
References: <1388133158-4142-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbaABIbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 03:31:04 -0500
In-Reply-To: <1388133158-4142-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 27 Dec 2013 16:32:38 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> since the prune parameter for fib6_clean_all always is 0, remove it.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
