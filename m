From: varkabhadram@gmail.com
Subject: [PATCH net-next 0/2] cleanup for realtek 8139CP
Date: Tue, 22 Jul 2014 11:28:46 +0530
Message-ID: <1406008728-22604-1-git-send-email-varkabhadram@gmail.com>
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:42057 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494AbaGVGAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 02:00:19 -0400
Received: by mail-pd0-f180.google.com with SMTP id y13so10466692pdi.25
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 23:00:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

Varka Bhadram (2):
  ethernet: realtek: use module_pci_driver
  ethernet: realtek: use pci_device_id

 drivers/net/ethernet/realtek/8139cp.c |   30 ++++++++----------------------
 1 file changed, 8 insertions(+), 22 deletions(-)

-- 
1.7.9.5
