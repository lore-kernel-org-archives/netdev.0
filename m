From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: [HELP] BAD interrupts
Date: Wed, 23 Dec 2009 19:47:15 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA0903A@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:45572 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755539AbZLWORT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 09:17:19 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nBNEHITf002268
	for <netdev@vger.kernel.org>; Wed, 23 Dec 2009 07:17:18 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id nBNEMpi2018815
	for <netdev@vger.kernel.org>; Wed, 23 Dec 2009 08:22:52 -0600 (CST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
 
I am trying linux 2.6.32-rc3 in SMP mode. I am seeing a lot of BAD
interrupts when I do a "cat  /proc/interrupts".
 
I am running a forwarding application b/w two ethernet ports (ethernet
uses gianfar driver).
 
Has any one observed these BAD interrupts ? If so, can someone help me
in understanding why these interrupts come and how to resolve it ?
 
 
--
 
Thanks
Sandeep 
