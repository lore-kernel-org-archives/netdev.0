From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] drivers/net: Use of_match_ptr() macro in smc91x.c
Date: Wed, 19 Dec 2012 12:50:29 -0800 (PST)
Message-ID: <20121219.125029.166752508334052816.davem@davemloft.net>
References: <1355915830-29481-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
	patches@linaro.org, nico@fluxnic.net
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592Ab2LSUua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 15:50:30 -0500
In-Reply-To: <1355915830-29481-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Wed, 19 Dec 2012 16:47:09 +0530

> This eliminates having an #ifdef returning NULL for the case
> when OF is disabled.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
