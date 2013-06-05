From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: sun4i-emac: Remove redundant
 platform_set_drvdata()
Date: Tue, 04 Jun 2013 17:40:22 -0700 (PDT)
Message-ID: <20130604.174022.965413187575972544.davem@davemloft.net>
References: <1370341880-26501-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sr@denx.de,
	maxime.ripard@free-electrons.com
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990Ab3FEAkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:40:23 -0400
In-Reply-To: <1370341880-26501-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Tue,  4 Jun 2013 16:01:19 +0530

> Commit 0998d06310 (device-core: Ensure drvdata = NULL when no
> driver is bound) removes the need to set driver data field to
> NULL.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
