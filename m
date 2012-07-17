From: Anatolij Gustschin <agust@denx.de>
Subject: Re: [PATCH v6 4/7] net, ethernet, davinci_emac: add OF support
Date: Tue, 17 Jul 2012 12:37:26 +0200
Message-ID: <20120717123726.356b2d3a@wker>
References: <1341823456-32297-1-git-send-email-hs@denx.de>
	<50044F05.6060707@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Heiko Schocher <hs@denx.de>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree-discuss@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Wolfgang Denk <wd@denx.de>, Anatoly Sivov <mm05@mail.ru>
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:33900 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759Ab2GQKhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 06:37:31 -0400
In-Reply-To: <50044F05.6060707@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 16 Jul 2012 22:57:33 +0530
Sekhar Nori <nsekhar@ti.com> wrote:

> Hi Dave,
> 
> On 7/9/2012 2:14 PM, Heiko Schocher wrote:
> > add of support for the davinci_emac driver.
> > 
> > Signed-off-by: Heiko Schocher <hs@denx.de>
> > Acked-by: Sekhar Nori <nsekhar@ti.com>
> > Cc: davinci-linux-open-source@linux.davincidsp.com
> > Cc: linux-arm-kernel@lists.infradead.org
> > Cc: devicetree-discuss@lists.ozlabs.org
> > Cc: netdev@vger.kernel.org
> > Cc: Grant Likely <grant.likely@secretlab.ca>
> > Cc: Sekhar Nori <nsekhar@ti.com>
> > Cc: Wolfgang Denk <wd@denx.de>
> > Cc: Anatoly Sivov <mm05@mail.ru>
> > Cc: David Miller <davem@davemloft.net>
> 
> Can you please consider this patch for v3.6? I tested it on DaVinci
> AM18x EVM with and without CONFIG_OF using NFS root.
> 
> This patch can be independently queued and does not have any dependencies.

unfortunately the patch didn't apply on net-next tree. I've
send a rebased patch.

Thanks,
Anatolij
