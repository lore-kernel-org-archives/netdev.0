From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 0/6] bnx2x: fixes
Date: Tue, 16 Jul 2013 18:21:41 +0300
Message-ID: <1373988107-305-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4140 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932727Ab3GPPV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 11:21:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave

Please consider applying the series of bnx2x fixes to net:
	* statistics may cause FW assert
	* missing fairness configuration in DCB flow
	* memory leak in sriov releated part
	* Illegal PTE access
	* Pagefault crash in shutdown flow with cnic

Thanks
Dmitry 
