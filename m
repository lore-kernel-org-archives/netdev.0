From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 0/9] bnx2x: FCoE support
Date: Mon, 13 Dec 2010 17:43:33 +0200
Message-ID: <1292255013.631.48.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Shmulik Ravid-Rabinovitz" <shmulikr@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1152 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480Ab0LMPnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 10:43:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

This patch-series adds FCoE support to 57712 HW. It provides
required intefaces for upper-level driver (CNIC) and handles
FCoE related HW/FW initialization and flows.

Since the FW files are too big (patches 6 and 8) and will not 
pass the mailing list, it is also located at:
http://linux.broadcom.com/eilong/1.62.00-2

It's a second attempt to submit this patch series after fixing
a Tx hash distribution fairness.

Thanks,
Vlad



