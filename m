From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] tcp: extract code to compute SYNACK RTT
Date: Sat, 22 Sep 2012 15:47:44 -0400 (EDT)
Message-ID: <20120922.154744.390036202729688723.davem@davemloft.net>
References: <1348323537-30310-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
	hkchu@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab2IVTrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 15:47:46 -0400
In-Reply-To: <1348323537-30310-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sat, 22 Sep 2012 10:18:54 -0400

> In preparation for adding another spot where we compute the SYNACK
> RTT, extract this code so that it can be shared.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
