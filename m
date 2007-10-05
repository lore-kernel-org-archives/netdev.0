From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/5] s390: qeth and lcs patches for 2.6.24 - RESEND
Date: Fri, 05 Oct 2007 16:45:43 +0200
Message-ID: <20071005144543.448852000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:57577 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755344AbXJEOsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 10:48:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-- 
Sorry, 2nd attempt, because patch 5/5 missed title line

The following patches in qeth and lcs driver are intended for 2.6.24:
- qeth: drop non-IP outbound packets on HiperSocket devices
- qeth: EDDP-mode - correct filling of qdio buffers
- qeth: avoid duplicate deletion of multicast addresses
- lcs:  avoid kernel panic in lcs_recovery driven by channel errors
- qeth: discard inbound packets with unknown header id


