From: Li Yang <leoli@freescale.com>
Subject: [PATCH 0/2] ucc_geth fixes for 2.6.26
Date: Fri, 23 May 2008 18:11:25 +0800
Message-ID: <1211537487-24953-1-git-send-email-leoli@freescale.com>
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:54229 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbYEWJ7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 05:59:38 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id m4N9xZiP004333
	for <netdev@vger.kernel.org>; Fri, 23 May 2008 02:59:35 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id m4N9xXcb027564
	for <netdev@vger.kernel.org>; Fri, 23 May 2008 04:59:34 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Please apply the following fixes for ucc_geth.

Joakim Tjernlund (1):
      ucc_geth_ethtool: Fix typo

Li Yang (1):
      ucc_geth_ethtool: Add a missing HW stats counter

