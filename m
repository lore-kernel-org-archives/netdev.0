From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] isdn: Remove left over conflict marker in Docmentation/isdn/00-INDEX
Date: Fri, 19 Jun 2009 03:27:43 -0700
Message-ID: <m18wjobjs0.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38971 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571AbZFSK1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 06:27:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In merge:
   commit aba7453037c3a90714caae77a622dceaf1173786
   Merge: a4fe91e... 93af7ac...
   Author: David S. Miller <davem@davemloft.net>
   Date:   Wed Apr 29 20:30:35 2009 -0700
   
       Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
   
       Conflicts:
           Documentation/isdn/00-INDEX
           drivers/net/wireless/iwlwifi/iwl-scan.c
           drivers/net/wireless/rndis_wlan.c
           net/mac80211/main.c

The following useless line was retained.

>>>>>>> 93af7aca44f0e82e67bda10a0fb73d383edcc8bd:Documentation/isdn/00-INDEX

Delete it and leave 00-INDEX looking reasonable.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 Documentation/isdn/00-INDEX |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/Documentation/isdn/00-INDEX b/Documentation/isdn/00-INDEX
index f6010a5..e6ff335 100644
--- a/Documentation/isdn/00-INDEX
+++ b/Documentation/isdn/00-INDEX
@@ -22,7 +22,6 @@ README.gigaset
 	- info on the drivers for Siemens Gigaset ISDN adapters.
 README.icn
 	- info on the ICN-ISDN-card and its driver.
->>>>>>> 93af7aca44f0e82e67bda10a0fb73d383edcc8bd:Documentation/isdn/00-INDEX
 README.HiSax
 	- info on the HiSax driver which replaces the old teles.
 README.audio
-- 
1.6.0.6

