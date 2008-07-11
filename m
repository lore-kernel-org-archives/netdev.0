From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH 6/6] ucc_geth: delete non NAPI code from the driver.
Date: Fri, 11 Jul 2008 11:38:34 +0800
Message-ID: <989B956029373F45A0B8AF0297081890027C4A15@zch01exm26.fsl.freescale.net>
References: <20080707.224336.59099363.davem@davemloft.net> <20080708070106.GA30382@electric-eye.fr.zoreil.com> <20080708.015548.127198943.davem@davemloft.net> <20080710223440.GF31019@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>,
	"Fleming Andy" <afleming@freescale.com>
To: "Francois Romieu" <romieu@fr.zoreil.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:62374 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbYGKDil convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 23:38:41 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m6B3cbUx016959
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 20:38:38 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id m6B3cam1029229
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 22:38:36 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20080710223440.GF31019@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Friday, July 11, 2008 6:35 AM
> To: David Miller
> Cc: jeff@garzik.org; netdev@vger.kernel.org; Fleming Andy; Li Yang
> Subject: [PATCH 6/6] ucc_geth: delete non NAPI code from the driver.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

I thought NAPI is left as an option because it adds the latency.  Is it
not the case any more?

- Leo
