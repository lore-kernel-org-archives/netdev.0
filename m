From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] ipv4: remove ip_rt_dump from route.c
Date: Fri, 21 Mar 2014 15:38:44 -0400 (EDT)
Message-ID: <20140321.153844.1012685520499183330.davem@davemloft.net>
References: <1395372790-11056-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbaCUTiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 15:38:46 -0400
In-Reply-To: <1395372790-11056-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 21 Mar 2014 11:33:10 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> ip_rt_dump do nothing after IPv4 route caches removal, so we can remove it.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
