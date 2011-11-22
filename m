From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: correct comments of skb_shift
Date: Tue, 22 Nov 2011 16:19:12 -0500 (EST)
Message-ID: <20111122.161912.1665345119233344451.davem@davemloft.net>
References: <1321876031-2543-1-git-send-email-kinwin2008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kinwin2008@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757409Ab1KVVTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 16:19:15 -0500
In-Reply-To: <1321876031-2543-1-git-send-email-kinwin2008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Feng King <kinwin2008@gmail.com>
Date: Mon, 21 Nov 2011 19:47:11 +0800

> when skb_shift, we want to shift paged data from skb to tgt frag area.
> Original comments revert the shift order
> 
> Signed-off-by: Feng King <kinwin2008@gmail.com>

Applied, thank you.
