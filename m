From: Gabriel Paubert <paubert@iram.es>
Subject: Re: [PATCH] Allow selecting mv643xx_eth on Pegasos again
Date: Tue, 19 May 2009 00:18:47 +0200
Message-ID: <20090518221847.GA17348@iram.es>
References: <20090518173756.GA11805@iram.es> <598D5675D34BE349929AF5EDE9B03E2702C2D323@az33exm24.fsl.freescale.net> <20090518184752.GA12972@iram.es> <598D5675D34BE349929AF5EDE9B03E2702C2D3A5@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, tbm@cyrius.com,
	LinuxPPC <linuxppc-dev@ozlabs.org>, pacman@kosh.dhis.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Medve Emilian-EMMEDVE1 <Emilian.Medve@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gra-lx1.iram.es ([150.214.224.41]:50545 "EHLO gra-lx1.iram.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754280AbZERWS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 18:18:58 -0400
Content-Disposition: inline
In-Reply-To: <598D5675D34BE349929AF5EDE9B03E2702C2D3A5@az33exm24.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Medve

On Mon, May 18, 2009 at 01:15:12PM -0700, Medve Emilian-EMMEDVE1 wrote:
> 
> You're correct. MV64360 seems to be stale. Do you want to re-spin your
> patch to get rid of it?


No problem, bu should I respin in from the current official git
or on top of yours?

> 
> (I wouldn't create a dependency between MV643XX_ETH and PPC_CHRP.)

Fine with me.

	Regards,
	Gabriel
