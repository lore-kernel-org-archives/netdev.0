From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/12] drivers/net/ethernet/cadence: don't use
 devm_pinctrl_get_select_default() in probe
Date: Thu, 11 Jul 2013 17:19:01 -0700 (PDT)
Message-ID: <20130711.171901.2111938252939851650.davem@davemloft.net>
References: <1373471889-18107-1-git-send-email-wsa@the-dreams.de>
	<1373471889-18107-8-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, nicolas.ferre@atmel.com,
	netdev@vger.kernel.org
To: wsa@the-dreams.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932096Ab3GLATC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 20:19:02 -0400
In-Reply-To: <1373471889-18107-8-git-send-email-wsa@the-dreams.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <wsa@the-dreams.de>
Date: Wed, 10 Jul 2013 16:57:43 +0100

> Since commit ab78029 (drivers/pinctrl: grab default handles from device core),
> we can rely on device core for setting the default pins. Compile tested only.
> 
> Acked-by: Linus Walleij <linus.walleij@linaro.org> (personally at LCE13)
> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>

Applied.
