From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH]drivers:isdn:istream.c Fix typo pice to piece
Date: Sun, 20 Feb 2011 22:31:21 -0800
Message-ID: <1298269881-2754-1-git-send-email-justinmattock@gmail.com>
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:35501 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778Ab1BUGbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 01:31:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The below patch changes a typo "pice" to "piece"

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 drivers/isdn/hardware/eicon/istream.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/istream.c b/drivers/isdn/hardware/eicon/istream.c
index 18f8798..7bd5baa 100644
--- a/drivers/isdn/hardware/eicon/istream.c
+++ b/drivers/isdn/hardware/eicon/istream.c
@@ -62,7 +62,7 @@ void diva_xdi_provide_istream_info (ADAPTER* a,
   stream interface.
   If synchronous service was requested, then function
   does return amount of data written to stream.
-  'final' does indicate that pice of data to be written is
+  'final' does indicate that piece of data to be written is
   final part of frame (necessary only by structured datatransfer)
   return  0 if zero lengh packet was written
   return -1 if stream is full
-- 
1.6.5.2.180.gc5b3e

