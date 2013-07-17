From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net v3 0/6] bnx2x: fixes
Date: Thu, 18 Jul 2013 01:00:34 +0300
Message-ID: <1374098440-27877-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1537 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752433Ab3GQWBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jul 2013 18:01:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave

Please consider applying the series of bnx2x fixes to net:
	* statistics may cause FW assert
	* missing fairness configuration in DCB flow
	* memory leak in sriov releated part
	* Illegal PTE access
	* Pagefault crash in shutdown flow with cnic

v1->v2
	* fixed sparse error pointed by Joe Perches
	* added missing signed-off from Sergei Shtylyov
v2->v3
	* added missing signed-off from Sergei Shtylyov
	* fixed formatting from Sergei Shtylyov
Thanks
Dmitry 
