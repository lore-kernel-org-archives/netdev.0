From: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>
Subject: RE: [PATCH] Allow selecting mv643xx_eth on Pegasos again
Date: Mon, 18 May 2009 15:53:06 -0700
Message-ID: <598D5675D34BE349929AF5EDE9B03E2702C2D459@az33exm24.fsl.freescale.net>
References: <20090518173756.GA11805@iram.es> <598D5675D34BE349929AF5EDE9B03E2702C2D323@az33exm24.fsl.freescale.net> <20090518184752.GA12972@iram.es> <598D5675D34BE349929AF5EDE9B03E2702C2D3A5@az33exm24.fsl.freescale.net> <20090518221847.GA17348@iram.es>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Lennert Buytenhek" <buytenh@wantstofly.org>, <tbm@cyrius.com>,
	"LinuxPPC" <linuxppc-dev@ozlabs.org>, <pacman@kosh.dhis.org>,
	<netdev@vger.kernel.org>, "David Miller" <davem@davemloft.net>
To: "Gabriel Paubert" <paubert@iram.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35390 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433AbZERWxT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 18:53:19 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n4IMr7Iw008972
	for <netdev@vger.kernel.org>; Mon, 18 May 2009 15:53:10 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id n4IMr7xv017901
	for <netdev@vger.kernel.org>; Mon, 18 May 2009 17:53:07 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20090518221847.GA17348@iram.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Gabriel,


> -----Original Message-----
> From: Gabriel Paubert [mailto:paubert@iram.es]
> Sent: Monday, May 18, 2009 5:19 PM
> To: Medve Emilian-EMMEDVE1
> Cc: Lennert Buytenhek; tbm@cyrius.com; LinuxPPC; pacman@kosh.dhis.org;
netdev@vger.kernel.org; David
> Miller
> Subject: Re: [PATCH] Allow selecting mv643xx_eth on Pegasos again
> 
> Hello Medve
> 
> On Mon, May 18, 2009 at 01:15:12PM -0700, Medve Emilian-EMMEDVE1
wrote:
> >
> > You're correct. MV64360 seems to be stale. Do you want to re-spin
your
> > patch to get rid of it?
> 
> 
> No problem, bu should I respin in from the current official git
> or on top of yours?

Top of the tree should be good.


Cheers,
Emil.


> > (I wouldn't create a dependency between MV643XX_ETH and PPC_CHRP.)
> 
> Fine with me.
> 
> 	Regards,
> 	Gabriel
