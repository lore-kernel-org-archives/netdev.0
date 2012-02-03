From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 0/2] be2net fixes
Date: Sat, 4 Feb 2012 01:19:18 +0530
Message-ID: <0a5c8174-e432-4ff3-91af-43f9838f41da@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:30563 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754059Ab2BCTu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 14:50:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.
Thanks,
Padmanabh

Padmanabh Ratnakar (2):
  be2net: Fix link status query command
  be2net: Use new implementation of get mac list command

 drivers/net/ethernet/emulex/benet/be_cmds.c |   73 +++++++++++++++++++--------
 drivers/net/ethernet/emulex/benet/be_cmds.h |   36 +++++++++----
 drivers/net/ethernet/emulex/benet/be_main.c |   29 +++++++----
 3 files changed, 96 insertions(+), 42 deletions(-)
