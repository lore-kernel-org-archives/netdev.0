From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH] Fix ethernet multicast for ucc_geth.
Date: Sun, 21 Oct 2007 11:45:48 +0200
Message-ID: <005801c813c7$2936b550$5267a8c0@Jocke>
References: <989B956029373F45A0B8AF0297081890019B5BD2@zch01exm26.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'Li Yang-r58472'" <LeoLi@freescale.com>,
	"'Netdev'" <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:20237 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750987AbXJUJpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 05:45:55 -0400
In-Reply-To: <989B956029373F45A0B8AF0297081890019B5BD2@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Li Yang-r58472 [mailto:LeoLi@freescale.com] 
> Sent: den 18 oktober 2007 16:24
> To: joakim.tjernlund@transmode.se; Netdev; linuxppc-dev@ozlabs.org
> Subject: RE: [PATCH] Fix ethernet multicast for ucc_geth.
> 
> > -----Original Message-----
> > From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se] 
> > Sent: Wednesday, October 17, 2007 5:06 PM
> > To: Netdev; Li Yang-r58472
> > Subject: [PATCH] Fix ethernet multicast for ucc_geth.
> > 
> > >From 5761a9e5924b34615c748fba2dcb977ed04c1243 Mon Sep 17 
> > 00:00:00 2001
> > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > Date: Wed, 17 Oct 2007 11:01:44 +0200
> > Subject: [PATCH] Fix ethernet multicast for ucc_geth.
> >  hw_add_addr_in_hash() already swaps byte  order, don't do it 
> > in ucc_geth_set_multi() too.
> > 
> > 
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> 
> Acked-by: Li Yang <leoli@freescale.com>
> 

Ping? Did this make into a someones tree?

 Jocke

