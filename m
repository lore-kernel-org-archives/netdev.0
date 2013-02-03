From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix inner_network_header assignment in skb-copy.
Date: Sun, 03 Feb 2013 16:11:07 -0500 (EST)
Message-ID: <20130203.161107.112468876048257967.davem@davemloft.net>
References: <1359767929-1875-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650Ab3BCVLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 16:11:09 -0500
In-Reply-To: <1359767929-1875-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Fri,  1 Feb 2013 17:18:49 -0800

> Use correct inner offset to set inner_network_offset.
> Found by inspection.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.
