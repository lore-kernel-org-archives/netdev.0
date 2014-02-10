From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vxge: Remove unused device pointer
Date: Sun, 09 Feb 2014 19:11:36 -0800 (PST)
Message-ID: <20140209.191136.502216712263464439.davem@davemloft.net>
References: <20140209001617.1d1543d4@spike>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org, kaber@trash.net,
	jg1.han@samsung.com, standby24x7@gmail.com, john.stultz@linaro.org,
	dingtianhong@huawei.com, bhutchings@solarflare.com,
	stephen@networkplumber.org, therbert@google.com
To: cengelma@gmx.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbaBJDLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 22:11:37 -0500
In-Reply-To: <20140209001617.1d1543d4@spike>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Engelmayer <cengelma@gmx.at>
Date: Sun, 9 Feb 2014 00:16:17 +0100

> Remove occurrences of unused struct __vxge_hw_device pointer in functions
> vxge_learn_mac() and vxge_rem_isr().
> 
> Detected by Coverity: CID 139839, CID 139842.
> 
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>

Applied, thank you.
