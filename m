From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix cdc-phonet build
Date: Wed, 27 Jul 2011 22:41:17 -0700 (PDT)
Message-ID: <20110727.224117.389682636642939049.davem@davemloft.net>
References: <201107262320.22338.chris2553@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chris2553@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754774Ab1G1FlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:41:20 -0400
In-Reply-To: <201107262320.22338.chris2553@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Clayton <chris2553@googlemail.com>
Date: Tue, 26 Jul 2011 23:20:22 +0100

> cdc-phonet does not presently build on linux-3.0 because there is no entry for it in 
> drivers/net/Makefile. This patch adds that entry.
> 
> Signed-off-by: Chris Clayton <chris2553@googlemail.com>

Applied, thanks.
