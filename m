From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] Fix ethernet multicast for ucc_geth.
Date: Thu, 18 Oct 2007 22:24:00 +0800
Message-ID: <989B956029373F45A0B8AF0297081890019B5BD2@zch01exm26.fsl.freescale.net>
References: <1192611942.7848.19.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <joakim.tjernlund@transmode.se>, "Netdev" <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:45914 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763523AbXJROYI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 10:24:08 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l9IEO41P021620
	for <netdev@vger.kernel.org>; Thu, 18 Oct 2007 07:24:04 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l9IEO22o018727
	for <netdev@vger.kernel.org>; Thu, 18 Oct 2007 09:24:03 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <1192611942.7848.19.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se] 
> Sent: Wednesday, October 17, 2007 5:06 PM
> To: Netdev; Li Yang-r58472
> Subject: [PATCH] Fix ethernet multicast for ucc_geth.
> 
> >From 5761a9e5924b34615c748fba2dcb977ed04c1243 Mon Sep 17 
> 00:00:00 2001
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Wed, 17 Oct 2007 11:01:44 +0200
> Subject: [PATCH] Fix ethernet multicast for ucc_geth.
>  hw_add_addr_in_hash() already swaps byte  order, don't do it 
> in ucc_geth_set_multi() too.
> 
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Acked-by: Li Yang <leoli@freescale.com>
