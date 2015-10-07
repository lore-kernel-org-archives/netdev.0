From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3][RESEND] doc: dt: net: Add fsl,wake-on-filer for
 eTSEC
Date: Wed, 07 Oct 2015 04:20:14 -0700 (PDT)
Message-ID: <20151007.042014.1485696570433453264.davem@davemloft.net>
References: <1444054799-17876-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leoli@freescale.com,
	chenhui.zhao@freescale.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbbJGLEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 07:04:30 -0400
In-Reply-To: <1444054799-17876-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Mon, 5 Oct 2015 17:19:57 +0300

> Add the "fsl,wake-on-filer" property for eTSEC nodes to
> indicate that the system has the power management
> infrastructure needed to be able to wake up the system
> via FGPI (filer, aka. h/w rx parser) interrupt.
> 
> Cc: Li Yang <leoli@freescale.com>
> Cc: Zhao Chenhui <chenhui.zhao@freescale.com>
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
> Patch initially sent to the ppc-devel list,
> resend it to the netdev list:
> http://patchwork.ozlabs.org/patch/524902/

Applied.
