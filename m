From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 2/2] net: make skb an optional parameter
 for__skb_flow_dissect()
Date: Mon, 25 Aug 2014 17:22:07 -0700 (PDT)
Message-ID: <20140825.172207.637339463517885008.davem@davemloft.net>
References: <1409011427-18438-1-git-send-email-xiyou.wangcong@gmail.com>
	<1409011427-18438-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaHZAWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:22:08 -0400
In-Reply-To: <1409011427-18438-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 25 Aug 2014 17:03:47 -0700

> Fixes: commit 690e36e726d00d2 (net: Allow raw buffers to be passed into the flow dissector)
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
