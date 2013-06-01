From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 0/6] ARM: sunxi: Add support for A10 Ethernet
 controller
Date: Fri, 31 May 2013 17:23:36 -0700 (PDT)
Message-ID: <20130531.172336.1848458955586893446.davem@davemloft.net>
References: <1369921765-3367-1-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sr@denx.de, florian@openwrt.org,
	emilio@elopez.com.ar, kevin@allwinnertech.com,
	sunny@allwinnertech.com, shuge@allwinnertech.com
To: maxime.ripard@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43279 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757851Ab3FAAXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:23:37 -0400
In-Reply-To: <1369921765-3367-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxime Ripard <maxime.ripard@free-electrons.com>
Date: Thu, 30 May 2013 15:49:19 +0200

> The Allwinner A10 SoC has an ethernet controller that seem to be specific to
> Allwinner. This IP has no public documentation, so exact
> details are quite sparse, and this code come from refactored Allwinner
> code.
> 
> The rework to use NAPI is taking more time than expected, I'm still working
> on it, but it could probably be sent as a follow-up patch.

Looks good.

All applied to net-next, thanks.
