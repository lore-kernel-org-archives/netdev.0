From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/6] net: bcmgenet: checkpatch fixes
Date: Tue, 22 Jul 2014 10:55:12 -0700
Message-ID: <1406051718-15883-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34051 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbaGVRzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 13:55:33 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so6654pdj.12
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 10:55:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains cleanups for CHECK and WARNINGS reported by
checkpatch.pl.

Thanks!

Florian Fainelli (6):
  net: bcmgenet: remove FSF mail address
  net: bcmgenet: add missing blank line after declaration
  net: bcmgenet: re-align multiple lines correctly
  net: bcmgenet: add and remove missing blank lines
  net: bcmgenet: add missing braces to some if statements
  net: bcmgenet: use kcalloc instead of kzalloc

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 283 ++++++++++++-------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  20 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |  39 ++--
 3 files changed, 155 insertions(+), 187 deletions(-)

-- 
1.9.1
