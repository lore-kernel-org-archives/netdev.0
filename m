From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/1] dccp ccid-3: Fix RFC reference
Date: Sat, 10 Jan 2009 18:47:04 +0100
Message-ID: <20090110174704.GA4648@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:55314 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752616AbZAJRrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 12:47:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dccp ccid-3: Fix RFC reference

Thanks to Wei and Arnaldo for pointing out the correct
new reference for CCID-3.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -29,7 +29,7 @@ config IP_DCCP_CCID3
 	  http://www.ietf.org/rfc/rfc4342.txt
 
 	  The TFRC congestion control algorithms were initially described in
-	  RFC 5448.
+	  RFC 5348.
 
 	  This text was extracted from RFC 4340 (sec. 10.2),
 	  http://www.ietf.org/rfc/rfc4340.txt
