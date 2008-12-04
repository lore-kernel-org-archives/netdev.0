From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] powerpc/83xx: Enable FIXED_PHY in mpc834x_itx and mpc83xx
 defconfigs
Date: Thu, 04 Dec 2008 13:18:23 -0600
Message-ID: <49382CFF.2050602@freescale.com>
References: <ed82fe3e0812040915i696e99bep75a37b0e38154415@mail.gmail.com> <20081204175231.GA28554@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, afleming@freescale.com
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:59803 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbYLDTS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 14:18:58 -0500
In-Reply-To: <20081204175231.GA28554@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:

> The FIXED_PHY driver isn't enabled in the defconfig. Following
> patch should fix the issue.
> 
>  arch/powerpc/configs/83xx/mpc834x_itx_defconfig |    2 +-
>  arch/powerpc/configs/mpc83xx_defconfig          |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

Acked-by: Timur Tabi <timur@freescale.com>

Kumar, please apply.

-- 
Timur Tabi
Linux kernel developer at Freescale
