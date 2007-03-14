From: Maciek <lms@inetcafe.eu.org>
Subject: No buffer space available
Date: Wed, 14 Mar 2007 16:10:45 +0100
Message-ID: <711119062.20070314161045@inetcafe.eu.org>
Reply-To: Maciek <lms@inetcafe.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.isb.com.pl ([80.48.198.2]:42427 "EHLO isb.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149AbXCNPlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2007 11:41:08 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by isb.com.pl (Postfix) with ESMTP id 3421BB2D6F
	for <netdev@vger.kernel.org>; Wed, 14 Mar 2007 16:13:37 +0100 (CET)
Received: from isb.com.pl ([127.0.0.1])
	by localhost (isb.com.pl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 10288-08 for <netdev@vger.kernel.org>;
	Wed, 14 Mar 2007 16:13:35 +0100 (CET)
Received: from piechcio (jota.isb.com.pl [80.48.198.14])
	(using TLSv1 with cipher DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by isb.com.pl (Postfix) with ESMTP id E4D49B2D6E
	for <netdev@vger.kernel.org>; Wed, 14 Mar 2007 16:13:35 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
   I have router PC based on Debian Sarge with kernel 2.6.17-14 and 1 ATM card (PROSUM PROATM-155FM)
  and 3 ethernet cards(2xIntel pro 100 + 1xBroadcom gbit). This server has 1GB Ram. Kernel was patched
  with PROSUM drivers (nicstar2.tgz).
   Sometimes I have problem with this router. Ever few days router lose connection with ATM gateway.
   
  When I try to send icmp packet to gateway I got message:
    ping: sendto: No buffer space available ping
    
  To connect again with atm gateway I must restart router.

