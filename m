From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Allow selecting mv643xx_eth on Pegasos again
Date: Mon, 18 May 2009 19:35:49 -0700 (PDT)
Message-ID: <20090518.193549.98339424.davem@davemloft.net>
References: <20090518221847.GA17348@iram.es>
	<598D5675D34BE349929AF5EDE9B03E2702C2D459@az33exm24.fsl.freescale.net>
	<20090518232113.GA18469@iram.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Emilian.Medve@freescale.com, buytenh@wantstofly.org,
	tbm@cyrius.com, linuxppc-dev@ozlabs.org, pacman@kosh.dhis.org,
	netdev@vger.kernel.org
To: paubert@iram.es
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40730
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753218AbZESCfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 22:35:51 -0400
In-Reply-To: <20090518232113.GA18469@iram.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gabriel Paubert <paubert@iram.es>
Date: Tue, 19 May 2009 01:21:13 +0200

> Since PPC_MUTIPLATFORM was removed, it was impossible to select the
> driver for mv643xx_eth on the Pegasos. Fix it and take the opportunity
> to remove the stale MV64360 config option.
> 
> Signed-off-by: Gabriel Paubert <paubert@iram.es>

This patch doesn't even apply to net-next-2.6, please send me
changes relative to that.
