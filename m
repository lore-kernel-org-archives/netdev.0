From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: [PATCH 6/6] [CRYPTO] added the developer of Camellia cipher
 algorithm.
Date: Wed, 18 Oct 2006 16:18:18 +0900 (JST)
Message-ID: <20061018.161818.607093092.takamiya@po.ntts.co.jp>
References: <20061018.161510.796986352.takamiya@po.ntts.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, takamiya@po.ntts.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ics.ntts.co.jp ([202.32.24.42]:55707 "EHLO
	mail2.ics.ntts.co.jp") by vger.kernel.org with ESMTP
	id S1751055AbWJRHUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 03:20:49 -0400
To: linux-crypto@vger.kernel.org
In-Reply-To: <20061018.161510.796986352.takamiya@po.ntts.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds the developer of Camellia cipher algorithm.

Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

---

 Documentation/crypto/api-intro.txt |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

80a5df8127311212e99bd64103771de19c5908dd
diff --git a/Documentation/crypto/api-intro.txt b/Documentation/crypto/api-intro.txt
index 5a03a28..e41a79a 100644
--- a/Documentation/crypto/api-intro.txt
+++ b/Documentation/crypto/api-intro.txt
@@ -193,6 +193,7 @@ Original developers of the crypto algori
   Kartikey Mahendra Bhatt (CAST6)
   Jon Oberheide (ARC4)
   Jouni Malinen (Michael MIC)
+  NTT(Nippon Telegraph and Telephone Corporation) (Camellia)
 
 SHA1 algorithm contributors:
   Jean-Francois Dive
@@ -246,6 +247,9 @@ Tiger algorithm contributors:
 VIA PadLock contributors:
   Michal Ludvig
 
+Camellia algorithm contributors:
+  NTT(Nippon Telegraph and Telephone Corporation) (Camellia)
+
 Generic scatterwalk code by Adam J. Richter <adam@yggdrasil.com>
 
 Please send any credits updates or corrections to:
-- 
Noriaki TAKAMIYA

