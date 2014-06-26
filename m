From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/3] net: bcmgenet: misc fixes
Date: Thu, 26 Jun 2014 10:26:19 -0700
Message-ID: <1403803582-13472-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:52261 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756822AbaFZR0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 13:26:34 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so3471021qcv.12
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 10:26:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch set contains 3 smal fixes targeted at the 'net' tree.

Thanks!

Florian Fainelli (3):
  net: bcmgenet: disable clock before register_netdev
  net: bcmgenet: start with carrier off
  net: bcmgenet: do not set packet length for RX buffers

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

-- 
1.9.1
