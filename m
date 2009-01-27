From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: FEC Patches
Date: Tue, 27 Jan 2009 11:39:55 +0100
Message-ID: <1233052804-31228-1-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	frederic rodo <fred.rodo@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45672 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbZA0KkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:40:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all, hi Greg,

Sorry guys, sending this again. Of course I'm not 'y', just playing
git-send-email:

Who should the emails appear to be from? [Sascha Hauer <s.hauer@pengutronix.de>] y[es]
Emails will be sent from: y


These patches are an updated version from the ones I posted some time ago.
They give the FEC ethernet driver a facelift and turn it into a
platform_device driver. The Coldfire cores are still supported through
legacy ifdefs. The platform driver support has been tested on a
Freescale i.MX27 SoC.

Sascha



