From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] ipv4: remove ipv4_ifdown_dst from route.c
Date: Mon, 24 Mar 2014 00:21:07 -0400 (EDT)
Message-ID: <20140324.002107.1372538865435150194.davem@davemloft.net>
References: <1395630190-12586-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbaCXEVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 00:21:08 -0400
In-Reply-To: <1395630190-12586-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon, 24 Mar 2014 11:03:10 +0800

> From: Li RongQing <roy.qing.li@gmail.com> 
> 
> ipv4_ifdown_dst does nothing after IPv4 route caches removal,
> so we can remove it.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thank you.
