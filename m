From: Hao Zhang <hao5781286@gmail.com>
Subject: Fwd: [PATCH] net: ethernet: sfc: There is a typo, modify curent to current.
Date: Fri, 29 Sep 2017 19:53:58 +0800
Message-ID: <CAJeuY78Ra4AeWydF0+9ZzDFW8p6HpfXGm1seEVe=QTcWT8UBSA@mail.gmail.com>
References: <20170929101937.GA8963@arx-kt>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:35505 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752463AbdI2LyA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 07:54:00 -0400
Received: by mail-vk0-f68.google.com with SMTP id h191so260460vke.2
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 04:53:59 -0700 (PDT)
In-Reply-To: <20170929101937.GA8963@arx-kt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resend to maintainer.



Regards :)


---------- Forwarded message ----------
From: Hao Zhang <hao5781286@gmail.com>
Date: 2017-09-29 18:19 GMT+08:00
Subject: [PATCH] net: ethernet: sfc: There is a typo, modify curent to curr=
ent.
To: linux-net-drivers@solarflare.com, ecree@solarflare.com,
bkenward@solarflare.com
=E6=8A=84=E9=80=81=EF=BC=9A linux-kernel@vger.kernel.org, hao5781286@gmail.=
com


There is a typo, fix it by modify curent to current.

Signed-off-by: Hao Zhang <hao5781286@gmail.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h
b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 91fb54f..8bfc8d4 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -11505,7 +11505,7 @@

 /***********************************/
 /* MC_CMD_GET_SNAPSHOT_LENGTH
- * Obtain the curent range of allowable values for the SNAPSHOT_LENGTH
+ * Obtain the current range of allowable values for the SNAPSHOT_LENGTH
  * parameter to MC_CMD_INIT_RXQ.
  */
 #define MC_CMD_GET_SNAPSHOT_LENGTH 0x101
