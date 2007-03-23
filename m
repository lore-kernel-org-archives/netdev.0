From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH][SCTP]: Update SCTP Maintainers entry
Date: Fri, 23 Mar 2007 09:28:30 -0700
Message-ID: <1174667310.32169.9.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net, vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:38061 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059AbXCWQ2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 12:28:34 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2NGSWbC008552
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 12:28:32 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2NGSWYt258274
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 12:28:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2NGSWW8019834
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 12:28:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

I have asked Vlad Yasevich to take over the role of primary 
maintainer of SCTP and he has accepted it. He has been 
contributing to SCTP for more than 2 years and has become
more active than me in the past year.

Thanks
Sridhar

[SCTP]: Update SCTP Maintainers entry

Add Vlad Yasevich as the primary maintainer of SCTP and add a
link to the project website.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 MAINTAINERS |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6d8d5b9..d4bfb9d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2928,9 +2928,12 @@ L:	linux-scsi@vger.kernel.org
 S:	Maintained
 
 SCTP PROTOCOL
+P:	Vlad Yasevich
+M:	vladislav.yasevich@hp.com
 P:	Sridhar Samudrala
 M:	sri@us.ibm.com
 L:	lksctp-developers@lists.sourceforge.net
+W:	http://lksctp.sourceforge.net
 S:	Supported
 
 SCx200 CPU SUPPORT


