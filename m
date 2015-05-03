From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] ipv4: remove the unnecessary codes in
 fib_info_hash_move
Date: Sat, 02 May 2015 22:18:24 -0400 (EDT)
Message-ID: <20150502.221824.285386324821077649.davem@davemloft.net>
References: <1430385912-21987-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbbECCS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 22:18:28 -0400
In-Reply-To: <1430385912-21987-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 30 Apr 2015 17:25:12 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The whole hlist will be moved, so not need to call hlist_del before
> add the hlist_node to other hlist_head.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
