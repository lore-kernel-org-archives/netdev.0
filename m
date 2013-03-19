From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/smsc911x: Use NULL instead of integer for
 pointer
Date: Tue, 19 Mar 2013 10:20:53 -0400 (EDT)
Message-ID: <20130319.102053.2263604273449486858.davem@davemloft.net>
References: <1363676498-9370-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab3CSOUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 10:20:54 -0400
In-Reply-To: <1363676498-9370-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Tue, 19 Mar 2013 12:31:38 +0530

> Silences the following sparse warning:
> drivers/net/ethernet/smsc/smsc911x.c:2145:30:
> warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied, thanks.
