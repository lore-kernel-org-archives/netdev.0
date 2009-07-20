From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH 0/3] can: various fixes to the device driver interface
Date: Mon, 20 Jul 2009 16:06:38 +0200
Message-ID: <20090720140638.342067093@denx.de>
Cc: socketcan-core@lists.berlios.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:46725 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824AbZGTOGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:06:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

this patch series fixes the following issues with CAN device driver
interface and the SJA1000 driver:

[PATCH 1/3] can: sja1000: remove duplicated includes
[PATCH 2/3] can: restart device even if dev_alloc_skb() fails
[PATCH 3/3] can: switch carrier on if device was stopped while in bus-off state

Wolfgang.


