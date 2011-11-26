From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9000: Fix check for disabled wake on LAN
Date: Sat, 26 Nov 2011 15:58:58 -0500 (EST)
Message-ID: <20111126.155858.77400285908658394.davem@davemloft.net>
References: <1321897916-5030-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patches@opensource.wolfsonmicro.com
To: broonie@opensource.wolfsonmicro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307Ab1KZU7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2011 15:59:03 -0500
In-Reply-To: <1321897916-5030-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Mon, 21 Nov 2011 17:51:56 +0000

> We're trying to check if any options are defined which isn't wha the
> existing code does due to confusing & and &&.
> 
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>

Good catch, applied, thanks.
