From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [Patch 1/3] ucc_geth: Fix BD processing
Date: Tue, 6 Mar 2007 19:15:54 +0800
Message-ID: <989B956029373F45A0B8AF02970818902DAA15@zch01exm26.fsl.freescale.net>
References: <45ED4C3C.2030109@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:36152 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965840AbXCFLOd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 06:14:33 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l26BEUaP029626
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 04:14:31 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l26BETYN021706
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 05:14:30 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <45ED4C3C.2030109@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org]
> Sent: Tuesday, March 06, 2007 7:11 PM
> To: Li Yang-r58472
> Cc: netdev@vger.kernel.org
> Subject: Re: [Patch 1/3] ucc_geth: Fix BD processing
> 
> Li Yang wrote:
> > Fix broken BD processing code.
> >
> > Signed-off-by: Michael Barkowski <michael.barkowski@freescale.com>
> > Signed-off-by: Li Yang <leoli@freescale.com>
> >
> > ---
> > drivers/net/ucc_geth.c |   14 +++++++++-----
> > 1 files changed, 9 insertions(+), 5 deletions(-)
> 
> applied 1-2 of 3

Thanks.  What's your comment about 3 of 3?

- Leo
