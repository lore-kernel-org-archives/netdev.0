From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove obsolete comment in
 ip6_append_data()
Date: Thu, 24 Jul 2014 23:48:35 -0700 (PDT)
Message-ID: <20140724.234835.2186763007050998297.davem@davemloft.net>
References: <1406270711-21752-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbaGYGsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:48:37 -0400
In-Reply-To: <1406270711-21752-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 25 Jul 2014 14:45:11 +0800

> From: Li RongQing <roy.qing.li@gmail.com> 
> 
> After 11878b40e[net-timestamp: SOCK_RAW and PING timestamping], this comment
> becomes obsolete since the codes check not only UDP socket, but also RAW sock;
> and the codes are clear, not need the comments
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
