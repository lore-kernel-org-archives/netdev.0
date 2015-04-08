From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] vxlan: fix a shadow local variable
Date: Wed, 08 Apr 2015 15:03:35 -0400 (EDT)
Message-ID: <20150408.150335.930888440139176514.davem@davemloft.net>
References: <1428513478-7852-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40488 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163AbbDHTDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 15:03:37 -0400
In-Reply-To: <1428513478-7852-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed,  8 Apr 2015 10:17:58 -0700

> Commit 79b16aadea32cce077
> ("udp_tunnel: Pass UDP socket down through udp_tunnel{, 6}_xmit_skb()")
> introduce 'sk' but we already have one inner 'sk'.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
