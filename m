From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: fec: Do a sanity check on the gpio number
Date: Mon, 18 Feb 2013 14:47:54 -0500 (EST)
Message-ID: <20130218.144754.591538350954943449.davem@davemloft.net>
References: <1361114964-10517-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, shawn.guo@linaro.org, marex@denx.de,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757136Ab3BRTr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 14:47:56 -0500
In-Reply-To: <1361114964-10517-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Sun, 17 Feb 2013 12:29:24 -0300

> Since commit 372e722ea4d (gpiolib: use descriptors internally) the following 
> warning is seen on a mx28evk board:

[davem@drr linux]$ git describe 372e722ea4d
fatal: Not a valid object name 372e722ea4d
[davem@drr linux]$ 

That commit ID doesn't exist in any tree I have access to.

I'm not applying this.
