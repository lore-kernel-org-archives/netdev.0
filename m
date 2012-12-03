From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: mvneta: Remove unneeded version.h header
 inclusion
Date: Mon, 03 Dec 2012 13:46:20 -0500 (EST)
Message-ID: <20121203.134620.972752091312747013.davem@davemloft.net>
References: <1354527928-27472-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	patches@linaro.org
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661Ab2LCSqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 13:46:22 -0500
In-Reply-To: <1354527928-27472-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Mon,  3 Dec 2012 15:15:28 +0530

> linux/version.h inclusion is not necessary.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Acked-by: David S. Miller <davem@davemloft.net>

I hope the mvneta folks will pick this up and apply it where it
needs to be as the mvneta driver isn't in the net-next tree.
