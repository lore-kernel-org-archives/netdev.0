From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pktgen: Observe needed_headroom of the device
Date: Wed, 29 Jul 2015 23:00:58 -0700 (PDT)
Message-ID: <20150729.230058.218703315508987990.davem@davemloft.net>
References: <1438163158-12554-1-git-send-email-bogdan.hamciuc@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bogdan.hamciuc@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbbG3GA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 02:00:59 -0400
In-Reply-To: <1438163158-12554-1-git-send-email-bogdan.hamciuc@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
Date: Wed, 29 Jul 2015 12:45:58 +0300

> Allocate enough space so as not to force the outgoing net device to do
> skb_realloc_headroom().
> 
> Signed-off-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>

Applied to net-next.
