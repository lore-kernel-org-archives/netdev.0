From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Cleanup in eth-netx.h
Date: Thu, 02 Jan 2014 03:31:39 -0500 (EST)
Message-ID: <20140102.033139.1859324028332823993.davem@davemloft.net>
References: <1388380316-1884-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patches@linaro.org, s.hauer@pengutronix.de
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbaABIbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 03:31:41 -0500
In-Reply-To: <1388380316-1884-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Mon, 30 Dec 2013 10:41:56 +0530

> Commit 2960ed346877 ("ARM: netx: move platform_data definitions")
> moved the file to the current location but forgot to remove the pointer
> to its previous location. Clean it up. While at it also change the header
> file protection macros appropriately.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
