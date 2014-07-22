From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/6] net: bcmgenet: checkpatch fixes
Date: Tue, 22 Jul 2014 10:58:56 -0700
Message-ID: <1406051942-18512-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:48518 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbaGVR7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 13:59:15 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so12945pab.6
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 10:59:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains cleanups for CHECK and WARNINGS reported by
checkpatch.pl.

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
