From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: i40evf: Remove duplicate include
Date: Mon, 17 Feb 2014 17:02:04 -0500 (EST)
Message-ID: <20140217.170204.832110487322855157.davem@davemloft.net>
References: <1392631161-17135-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51643 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbaBQWCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 17:02:06 -0500
In-Reply-To: <1392631161-17135-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Mon, 17 Feb 2014 15:29:21 +0530

> linux/sctp.h was included twice.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied to net-next, thank you.
