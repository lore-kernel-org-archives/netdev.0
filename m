From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] net: stmmac: dwmac-rk: add support for rk3368
Date: Tue, 23 Jun 2015 06:49:54 -0700 (PDT)
Message-ID: <20150623.064954.1515778425917492486.davem@davemloft.net>
References: <1434916374-7457-1-git-send-email-heiko@sntech.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, roger.chen@rock-chips.com,
	linux-rockchip@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbbFWNiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:38:05 -0400
In-Reply-To: <1434916374-7457-1-git-send-email-heiko@sntech.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Stuebner <heiko@sntech.de>
Date: Sun, 21 Jun 2015 21:52:50 +0200

> Apart from small cleanups, this series provides support for the dwmac
> on the new rk3368 ARM64 soc.
> 
> Tested on a R88 board using a RMII phy.
> 
> Changes since v1:
> - Adapt to changes resulting from patch d42202dce002 ("net: stmmac:
> dwmac-rk: Don't add function name in info or err messages")

Series applied to net-next, thanks.
