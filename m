From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: sun4i-emac: Staticize local symbols
Date: Tue, 04 Jun 2013 17:40:28 -0700 (PDT)
Message-ID: <20130604.174028.1751521780381783197.davem@davemloft.net>
References: <1370341880-26501-1-git-send-email-sachin.kamat@linaro.org>
	<1370341880-26501-2-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sr@denx.de,
	maxime.ripard@free-electrons.com
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251Ab3FEAk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:40:29 -0400
In-Reply-To: <1370341880-26501-2-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Tue,  4 Jun 2013 16:01:20 +0530

> Some symbols referenced only in this file are made static.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
