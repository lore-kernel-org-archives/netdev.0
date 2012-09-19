From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: fix comment in skb_try_coalesce
Date: Wed, 19 Sep 2012 17:29:45 -0400 (EDT)
Message-ID: <20120919.172945.445185592504949500.davem@davemloft.net>
References: <1348023201-7727-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930Ab2ISV3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 17:29:46 -0400
In-Reply-To: <1348023201-7727-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed, 19 Sep 2012 10:53:21 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> It should be the skb which is not cloned
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
