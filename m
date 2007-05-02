From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 0/20][BNX2]: Bug fixes and more 5709 suppot.
Date: Tue, 01 May 2007 18:11:43 -0700
Message-ID: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4694 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946051AbXEBAYs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 20:24:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David, please review and apply the following patches that will follow.
The firmware patches 6-11 will be sent to you off-list due to large
size.

[PATCH 1/20][BNX2]: Block MII access when ifdown.
[PATCH 2/20][BNX2]: Fix register and memory test on 5709.
[PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
[PATCH 4/20][BNX2]: Fix race conditions when calling register_netdev().
[PATCH 5/20][BNX2]: Save PCI state during suspend.
[PATCH 6/20][BNX2]: Update 5708 firmware.
[PATCH 7/20][BNX2]: Update 5709 firmware part 1.
[PATCH 8/20][BNX2]: Update 5709 firmware part 2.
[PATCH 9/20][BNX2]: Update 5709 firmware part 3.
[PATCH 10/20][BNX2]: Update 5709 firmware part 4.
[PATCH 11/20][BNX2]: Update 5709 firmware part 5.
[PATCH 12/20][BNX2]: Add ipv6 TSO and checksum for 5709.
[PATCH 13/20][BNX2]: Put MII register offsets in the bnx2 struct.
[PATCH 14/20][BNX2]: Re-structure the 2.5G Serdes code.
[PATCH 15/20][BNX2]: Add support for 5709 Serdes.
[PATCH 16/20][BNX2]: Add indirect spinlock.
[PATCH 17/20][BNX2]: Enhance the heartbeat.
[PATCH 18/20][BNX2]: Add 1-shot MSI handler for 5709.
[PATCH 19/20][BNX2]: Print bus information for PCIE devices.
[PATCH 20/20][BNX2]: Update version and reldate.


