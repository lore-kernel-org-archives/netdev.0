From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Add support for the ethernet ports on IXP43x
Date: Sat, 28 Jun 2008 14:04:06 +0200
Message-ID: <m3lk0pkbpl.fsf@maximus.localdomain>
References: <12144395181290-git-send-email-kaloz@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Imre Kaloz <kaloz@openwrt.org>,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:50120 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716AbYF1MEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jun 2008 08:04:09 -0400
In-Reply-To: <12144395181290-git-send-email-kaloz@openwrt.org> (Imre Kaloz's message of "Thu\, 26 Jun 2008 02\:18\:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Acked-by: Krzysztof Halasa <khc@pm.waw.pl>, seems sane.

Jeff, could you apply this please (post 2.6.26 I guess)?

Imre Kaloz <kaloz@openwrt.org> writes:

> Signed-off-by: Imre Kaloz <kaloz@openwrt.org>
>
> ---
>  arch/arm/mach-ixp4xx/ixp4xx_npe.c         |    6 +++---
>  drivers/net/arm/ixp4xx_eth.c              |   13 +++++++++----
>  include/asm-arm/arch-ixp4xx/cpu.h         |    2 ++
>  include/asm-arm/arch-ixp4xx/ixp4xx-regs.h |    7 ++++---
>  4 files changed, 18 insertions(+), 10 deletions(-)
-- 
Krzysztof Halasa
