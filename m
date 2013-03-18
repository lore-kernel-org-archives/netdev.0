From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: ftgmac100: Use module_platform_driver()
Date: Mon, 18 Mar 2013 13:03:11 -0400 (EDT)
Message-ID: <20130318.130311.544685063957517907.davem@davemloft.net>
References: <1363607448-17369-1-git-send-email-sachin.kamat@linaro.org>
	<1363607448-17369-3-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ratbert@faraday-tech.com
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab3CRRDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 13:03:14 -0400
In-Reply-To: <1363607448-17369-3-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Mon, 18 Mar 2013 17:20:48 +0530

> module_platform_driver macro removes some boilerplate and makes
> the code simpler.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
