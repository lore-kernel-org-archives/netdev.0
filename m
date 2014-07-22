From: varkabhadram@gmail.com
Subject: [PATCH net-next v2 0/2] cleanup for Realtek 8139CP
Date: Tue, 22 Jul 2014 12:50:20 +0530
Message-ID: <1406013622-27869-1-git-send-email-varkabhadram@gmail.com>
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34276 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaGVHWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 03:22:05 -0400
Received: by mail-pa0-f50.google.com with SMTP id et14so11555059pad.9
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 00:22:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

changes since v1:
	-removed unused varible warning

Varka Bhadram (2):
  ethernet: realtek: use module_pci_driver
  ethernet: realtek: use pci_device_id

 drivers/net/ethernet/realtek/8139cp.c |   36 +++++++++------------------------
 1 file changed, 9 insertions(+), 27 deletions(-)

-- 
1.7.9.5
