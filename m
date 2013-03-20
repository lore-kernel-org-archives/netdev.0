From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] net: mdio-gpio: Use module_platform_driver()
Date: Wed, 20 Mar 2013 13:26:14 -0400 (EDT)
Message-ID: <20130320.132614.122796743340415353.davem@davemloft.net>
References: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
	<1363779692-4395-4-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab3CTR0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:26:15 -0400
In-Reply-To: <1363779692-4395-4-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Wed, 20 Mar 2013 17:11:31 +0530

> module_platform_driver macro removes some boilerplate and
> simplifies the code.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
