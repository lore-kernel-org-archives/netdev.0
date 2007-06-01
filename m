From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH 2/5] phylib: enable RGMII-ID on the Marvell m88e1111 PHY
Date: Fri, 1 Jun 2007 13:48:45 +0800
Message-ID: <989B956029373F45A0B8AF0297081890D2A2FC@zch01exm26.fsl.freescale.net>
References: <20070511182502.31a8aad0.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Phillips Kim-R1AAHA" <Kim.Phillips@freescale.com>,
	"Jeff Garzik" <jeff@garzik.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:40491 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148AbXFAFrA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 01:47:00 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l515kvXv006312
	for <netdev@vger.kernel.org>; Thu, 31 May 2007 22:46:57 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l515kujw018903
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 00:46:56 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20070511182502.31a8aad0.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org] On
> Behalf Of Kim Phillips
> Sent: Saturday, May 12, 2007 7:25 AM
> To: Jeff Garzik; netdev@vger.kernel.org
> Subject: [PATCH 2/5] phylib: enable RGMII-ID on the Marvell m88e1111
PHY
> 
> Support for configuring RGMII-ID (RGMII with internal delay) mode on
the
> 88e1111 and 88e1145.
> 
> Also renamed 88e1111s -> 88e1111 (no references to an 88e1111s part
were
> found), and fixed some whitespace.
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
Acked-by: Li Yang <leoli@freescale.com>

This is truly a fix for MPC8360EMDS board which was working on 2.6.21.
Please push it to Linus in 2.6.22-rc phase rather than waiting until
2.6.23.  Thanks.

- Leo
