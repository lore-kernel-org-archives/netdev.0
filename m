From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] fec driver updates
Date: Wed, 27 Jun 2012 21:30:53 -0700 (PDT)
Message-ID: <20120627.213053.2138662759941342784.davem@davemloft.net>
References: <1340804724-29410-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LW@KARO-electronics.de, florian@openwrt.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org
To: shawn.guo@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab2F1Eay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 00:30:54 -0400
In-Reply-To: <1340804724-29410-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawn.guo@linaro.org>
Date: Wed, 27 Jun 2012 21:45:19 +0800

> Changes since v1:
> * Add one patch to use devm_gpio_request_one
> * Have a separate patch to fix phy-reset-gpios property in binding
>   document
> * Change phy-reset-interval to phy-reset-duration
> * Add a sanity check on phy-reset-duration value

All applied.
