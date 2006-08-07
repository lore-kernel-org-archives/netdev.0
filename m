From: Vitaly Bordug <vbordug@ru.mvista.com>
Subject: [PATCH 0/3] FS_ENET: move to the PAL api
Date: Tue, 08 Aug 2006 03:14:41 +0400
Message-ID: <20060807231441.13683.70528.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdma-45-249.msk.skylink.ru ([83.217.45.249]:37852 "EHLO
	localhost.localdomain") by vger.kernel.org with ESMTP
	id S932402AbWHGXbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:31:21 -0400
To: Jeff Garzik <jeff@garzik.org>
Cc: linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are patches, that utilize Phy Abstraction Layer API in the fs_enet
Freescale SoC Ethernet driver. Comments gavered from the community addressed,
+ minor fixes and improvements.

--
Sincerely, Vitaly
