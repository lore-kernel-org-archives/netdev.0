From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sunvnet: fix a memory leak in vnet_handle_offloads
Date: Fri, 19 Dec 2014 13:22:38 -0500 (EST)
Message-ID: <20141219.132238.788532371064146203.davem@davemloft.net>
References: <1418966375-23188-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbaLSSWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 13:22:41 -0500
In-Reply-To: <1418966375-23188-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 19 Dec 2014 13:19:35 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> when skb_gso_segment returns error, the original skb should be freed
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
