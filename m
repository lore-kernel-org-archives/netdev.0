From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth: kmalloc casting cleanups
Date: Tue, 9 Jan 2007 15:39:53 +0800
Message-ID: <989B956029373F45A0B8AF0297081890086680@zch01exm26.fsl.freescale.net>
References: <45A3412C.2050008@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:43237 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbXAIHis convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 02:38:48 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id l097clHH003306
	for <netdev@vger.kernel.org>; Tue, 9 Jan 2007 00:38:47 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l097cjaa020980
	for <netdev@vger.kernel.org>; Tue, 9 Jan 2007 01:38:46 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <45A3412C.2050008@garzik.org>
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org]
> Sent: Tuesday, January 09, 2007 3:16 PM
> To: Li Yang-r58472
> Cc: netdev@vger.kernel.org; galak@kernel.crashing.org
> Subject: Re: [PATCH] ucc_geth: kmalloc casting cleanups
> 
> Li Yang wrote:
> > From: Ahmed S. Darwish <darwish.07@gmail.com>
> >
> > Switch kmalloc to kzalloc and clean some redundant kmalloc
> > casts.
> >
> > Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
> > Signed-off-by: Li Yang <leoli@freescale.com>
> > ---
> 
> 
> I should wait for Kumar to resend ucc_geth fixes before applying this,
> right?

Ok.  The patch is based on 2.6.20-rc3, but I think it can still apply.
If not, please ping me.

- Leo
