From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/5] net: bcmgenet: checkpatch fixes
Date: Wed, 23 Jul 2014 10:42:10 -0700
Message-ID: <1406137335-1671-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:50515 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347AbaGWRnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 13:43:37 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so2027259pdj.28
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 10:43:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains cleanups for CHECK and WARNINGS reported by
checkpatch.pl. I removed one patch from this series since Joe reported
this was a false positive due to me not using the latest version.

Thanks!

Florian Fainelli (5):
  net: bcmgenet: remove FSF mail address
  net: bcmgenet: re-align multiple lines correctly
  net: bcmgenet: add and remove missing blank lines
  net: bcmgenet: add missing braces to some if statements
  net: bcmgenet: use kcalloc instead of kzalloc

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 285 ++++++++++++-------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  18 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |  39 ++--
 3 files changed, 154 insertions(+), 188 deletions(-)

-- 
1.9.1
