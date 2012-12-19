From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] drivers/net: Use of_match_ptr() macro in smsc911x.c
Date: Wed, 19 Dec 2012 12:50:34 -0800 (PST)
Message-ID: <20121219.125034.547377622082222306.davem@davemloft.net>
References: <1355915830-29481-1-git-send-email-sachin.kamat@linaro.org>
	<1355915830-29481-2-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
	patches@linaro.org, nico@fluxnic.net
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592Ab2LSUuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 15:50:35 -0500
In-Reply-To: <1355915830-29481-2-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Wed, 19 Dec 2012 16:47:10 +0530

> Add CONFIG_OF guard and use of_match_ptr macro.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
