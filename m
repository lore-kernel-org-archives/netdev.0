From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: make skb_dst_pop routine static
Date: Tue, 12 May 2015 23:20:04 -0400 (EDT)
Message-ID: <20150512.232004.1920587220759628519.davem@davemloft.net>
References: <1431426584-13603-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934004AbbEMDUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:20:05 -0400
In-Reply-To: <1431426584-13603-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 12 May 2015 18:29:44 +0800

> As xfrm_output_one() is the only caller of skb_dst_pop(), we should
> make skb_dst_pop() localized.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.
