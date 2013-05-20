From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] fec: Let device core handle pinctrl
Date: Mon, 20 May 2013 13:44:40 -0700 (PDT)
Message-ID: <20130520.134440.1135634217457548595.davem@davemloft.net>
References: <1369055178-6083-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756621Ab3ETUol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:44:41 -0400
In-Reply-To: <1369055178-6083-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Mon, 20 May 2013 10:06:17 -0300

> Since commit ab78029 (drivers/pinctrl: grab default handles from device core)
> we can rely on device core for handling pinctrl, so remove 
> devm_pinctrl_get_select_default() from the driver.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
