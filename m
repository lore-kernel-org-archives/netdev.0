From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 0/4] drivers/net/fec: Some cleanups and fix for DUAL MAC mode
Date: Mon, 21 Mar 2011 17:37:32 +0100
Message-ID: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: <u.kleine-koenig@pengutronix.de>,
	Shawn Guo <shawn.guo@freescale.com>,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:58243 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276Ab1CUQjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 12:39:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

patch 1/4: whitespace cleanup and spelling fixes
patch 2/4: use constants instead of bare numbers for register writes
patch 3/4: make dual MAC mode actually work
patch 4/4: take MAC address for second device from platform_data
           instead of using first MAC address + 1

