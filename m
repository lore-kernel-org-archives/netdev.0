From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [PATCH v6 4/7] net, ethernet, davinci_emac: add OF support
Date: Mon, 16 Jul 2012 22:57:33 +0530
Message-ID: <50044F05.6060707@ti.com>
References: <1341823456-32297-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Heiko Schocher <hs@denx.de>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree-discuss@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Wolfgang Denk <wd@denx.de>, Anatoly Sivov <mm05@mail.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:56583 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381Ab2GPR2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 13:28:23 -0400
In-Reply-To: <1341823456-32297-1-git-send-email-hs@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On 7/9/2012 2:14 PM, Heiko Schocher wrote:
> add of support for the davinci_emac driver.
> 
> Signed-off-by: Heiko Schocher <hs@denx.de>
> Acked-by: Sekhar Nori <nsekhar@ti.com>
> Cc: davinci-linux-open-source@linux.davincidsp.com
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: devicetree-discuss@lists.ozlabs.org
> Cc: netdev@vger.kernel.org
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Sekhar Nori <nsekhar@ti.com>
> Cc: Wolfgang Denk <wd@denx.de>
> Cc: Anatoly Sivov <mm05@mail.ru>
> Cc: David Miller <davem@davemloft.net>

Can you please consider this patch for v3.6? I tested it on DaVinci
AM18x EVM with and without CONFIG_OF using NFS root.

This patch can be independently queued and does not have any dependencies.

Thanks,
Sekhar
