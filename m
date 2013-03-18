From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] ARM: mxs: sanitize enet_out clock handling
Date: Mon, 18 Mar 2013 12:57:54 -0400 (EDT)
Message-ID: <20130318.125754.2279671208968144843.davem@davemloft.net>
References: <1363595185-12302-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: shawn.guo@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635Ab3CRQ54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 12:57:56 -0400
In-Reply-To: <1363595185-12302-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawn.guo@linaro.org>
Date: Mon, 18 Mar 2013 16:26:21 +0800

> If the series looks good to you, I hope I can have your ACK on the
> first 2 patches to have the series go via arm-soc tree for sake of
> git bisect.  Alternatively, please apply the first 2 on your tree
> for 3.10 and we will queue the platform patches for 3.11.

Feel free to apply these to arm-soc:

Acked-by: David S. Miller <davem@davemloft.net>
