From: Petri Gynther <pgynther@google.com>
Subject: [RESEND PATCH net-next v2 0/3] bcmgenet cleanups
Date: Tue,  5 Apr 2016 13:59:58 -0700
Message-ID: <1459890001-78171-1-git-send-email-pgynther@google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, opendmb@gmail.com,
	jaedon.shin@gmail.com, Petri Gynther <pgynther@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34037 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759797AbcDEVAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 17:00:16 -0400
Received: by mail-pf0-f178.google.com with SMTP id c20so18156923pfc.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 14:00:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three cleanup patches for bcmgenet.

Petri Gynther (3):
  net: bcmgenet: cleanup for bcmgenet_xmit()
  net: bcmgenet: cleanup for bcmgenet_xmit_frag()
  net: bcmgenet: cleanup for dmadesc_set()

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 27 ++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
