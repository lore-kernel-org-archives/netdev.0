From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: hisilicon: new hip04 MDIO driver
Date: Mon, 07 Apr 2014 14:47:01 -0400 (EDT)
Message-ID: <20140407.144701.2036781673003385871.davem@davemloft.net>
References: <1396672506-9296-1-git-send-email-zhangfei.gao@linaro.org>
	<1396672506-9296-3-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: zhangfei.gao@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510AbaDGSrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 14:47:04 -0400
In-Reply-To: <1396672506-9296-3-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhangfei Gao <zhangfei.gao@linaro.org>
Date: Sat,  5 Apr 2014 12:35:05 +0800

> +}
> +
> +
> +static int hip04_mdio_reset(struct mii_bus *bus)

Please one empty line between functions, not two.
