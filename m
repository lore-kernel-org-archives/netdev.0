From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 1/4] ethernet: arc: Add support for Rockchip SoC
 layer device tree bindings
Date: Tue, 09 Sep 2014 17:30:19 -0700 (PDT)
Message-ID: <20140909.173019.1085874055765706579.davem@davemloft.net>
References: <1410196490-5646-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko@sntech.de, linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, arnd@arndb.de
To: romain.perier@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaIJAaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 20:30:20 -0400
In-Reply-To: <1410196490-5646-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Romain Perier <romain.perier@gmail.com>
Date: Mon,  8 Sep 2014 17:14:47 +0000

> This patch defines a platform glue layer for Rockchip SoCs which
> support arc-emac driver. It ensures that regulator for the rmii is on
> before trying to connect to the ethernet controller. It applies right
> speed and mode changes to the grf when ethernet settings change.
> 
> Signed-off-by: Romain Perier <romain.perier@gmail.com>

Applied.
