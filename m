From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: using pskb_may_pull as early as possible
Date: Wed, 15 Oct 2014 23:33:40 -0400 (EDT)
Message-ID: <20141015.233340.675081432641866218.davem@davemloft.net>
References: <1413422238-2562-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbaJPDdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 23:33:42 -0400
In-Reply-To: <1413422238-2562-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 16 Oct 2014 09:17:18 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull should be used to check if skb->data has enough space,
> skb->len can not ensure that.
> 
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Also applied and queued up for -stable,thanks.
