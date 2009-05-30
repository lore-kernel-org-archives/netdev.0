From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [net-next-2.6 PATCH 0/3] can: sja1000: misused netdev->base_addr and OF platform driver
Date: Sat, 30 May 2009 19:55:47 +0200
Message-ID: <20090530175547.772116783@denx.de>
Cc: socketcan-core@lists.berlios.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:45870 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932537AbZE3Rzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 13:55:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

this patch series fixes some minor issues with the initial version of
the CAN device driver interface, corrects misusing netdev->base_addr and
adds the OF platform driver for the SJA1000.

Wolfgang.


