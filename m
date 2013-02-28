From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/phy: micrel: Disable asymmetric pause for
 KSZ9021
Date: Thu, 28 Feb 2013 15:40:08 -0500 (EST)
Message-ID: <20130228.154008.346192838829971364.davem@davemloft.net>
References: <1362077122-4266-1-git-send-email-ikosar@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ikosar@fit.vutbr.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47891 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760338Ab3B1UkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 15:40:10 -0500
In-Reply-To: <1362077122-4266-1-git-send-email-ikosar@fit.vutbr.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlastimil Kosar <ikosar@fit.vutbr.cz>
Date: Thu, 28 Feb 2013 19:45:22 +0100

> Phyter KSZ9021 has hardware bug. If asymmetric pause is enabled,
> then it is necessary to disconnect and then reconnect the ethernet
> cable to get the phyter working. The solution is to disable the
> asymmetric pause.
> 
> Signed-off-by: Vlastimil Kosar <ikosar@fit.vutbr.cz>

Applied, thanks.
