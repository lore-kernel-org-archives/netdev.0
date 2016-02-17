From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/7] fix IS_ERR_VALUE usage
Date: Wed, 17 Feb 2016 11:48:38 +0100
Message-ID: <7443859.JK6ybmGO1A@wuerfel>
References: <1455546925-22119-1-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Andrzej Hajda <a.hajda@samsung.com>, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-serial@vger.kernel.org,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:57787 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934008AbcBQKtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 05:49:11 -0500
In-Reply-To: <1455546925-22119-1-git-send-email-a.hajda@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 15 February 2016 15:35:18 Andrzej Hajda wrote:
> 
> Andrzej Hajda (7):
>   netfilter: fix IS_ERR_VALUE usage
>   MIPS: module: fix incorrect IS_ERR_VALUE macro usages
>   drivers: char: mem: fix IS_ERROR_VALUE usage
>   atmel-isi: fix IS_ERR_VALUE usage
>   serial: clps711x: fix IS_ERR_VALUE usage
>   fbdev: exynos: fix IS_ERR_VALUE usage
>   usb: gadget: fsl_qe_udc: fix IS_ERR_VALUE usage
> 

Can you Cc me the next time on all of the patches? I only got
three of them this time.

	Arnd
