From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Remove redundant null check before kfree in
 dev.c
Date: Tue, 20 Nov 2012 15:53:32 -0500 (EST)
Message-ID: <20121120.155332.2259835383523668561.davem@davemloft.net>
References: <1353409024-28853-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, patches@linaro.org
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292Ab2KTUxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 15:53:33 -0500
In-Reply-To: <1353409024-28853-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Tue, 20 Nov 2012 16:27:04 +0530

> kfree on a null pointer is a no-op.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
