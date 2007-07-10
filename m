From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: [PATCH] Fix typo in drivers/net/s2io.c
Date: Tue, 10 Jul 2007 11:58:02 +0200
Message-ID: <200707101158.03730.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sf-mail.de ([62.27.20.61]:50548 "EHLO mail.sf-mail.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756497AbXGJJ6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 05:58:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduced in d796fdb708fc5b10112934cba43e832c36ce4923.

Signed-off-by: Rolf Eike Beer <eike-kernel@sf-tec.de>

---
commit 58056c2424917e90b86ca11c2c5d3fd35313d7b6
tree 854d63a14f96416aad64d12ea71cb331acfcc7db
parent 87a2df362631d53fdc169a5d76969365aff69c10
author Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 10 Jul 2007 11:55:46 +0200
committer Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 10 Jul 2007 11:55:46 
+0200

 drivers/net/s2io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 2d826ff..fa29a40 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -8036,7 +8036,7 @@ static void lro_append_pkt(struct s2io_nic *sp, struct 
lro *lro,
 /**
  * s2io_io_error_detected - called when PCI error is detected
  * @pdev: Pointer to PCI device
- * @state: The current pci conneection state
+ * @state: The current pci connection state
  *
  * This function is called after a PCI bus error affecting
  * this device has been detected.
