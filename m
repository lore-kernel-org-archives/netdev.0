From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v5 1/4] ethernet: arc: Add support for Rockchip SoC layer device tree bindings
Date: Wed, 03 Sep 2014 20:17:37 +0200
Message-ID: <8915336.1DB5xPOmil@wuerfel>
References: <1409763165-16461-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Romain Perier <romain.perier@gmail.com>, heiko@sntech.de,
	linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:58236 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbaICSRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 14:17:47 -0400
In-Reply-To: <1409763165-16461-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 03 September 2014 16:52:42 Romain Perier wrote:
> This patch defines a platform glue layer for Rockchip SoCs which
> support arc-emac driver. It ensures that regulator for the rmii is on
> before trying to connect to the ethernet controller. It applies right
> speed and mode changes to the grf when ethernet settings change.
> 
> Signed-off-by: Romain Perier <romain.perier@gmail.com>
> 

Whole series

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
