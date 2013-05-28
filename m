From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/phy: Use module_spi_driver in spi_ks8995.c
Date: Mon, 27 May 2013 23:24:47 -0700 (PDT)
Message-ID: <20130527.232447.1369750001427894115.davem@davemloft.net>
References: <1369655499-17192-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, juhosg@openwrt.org
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932989Ab3E1GYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:24:47 -0400
In-Reply-To: <1369655499-17192-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Mon, 27 May 2013 17:21:39 +0530

> module_spi_driver() removes some boilerplate and makes the code
> simpler.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied, thanks.
