From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] net: ks8695net: Use module_platform_driver()
Date: Wed, 20 Mar 2013 13:25:55 -0400 (EDT)
Message-ID: <20130320.132555.688459794101823998.davem@davemloft.net>
References: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab3CTRZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:25:59 -0400
In-Reply-To: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Wed, 20 Mar 2013 17:11:28 +0530

> module_platform_driver macro removes some boilerplate and
> simplifies the code.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
