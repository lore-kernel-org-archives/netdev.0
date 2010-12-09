From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next 0/8] bnx2x: FCoE support
Date: Thu, 9 Dec 2010 14:08:18 +0200
Message-ID: <1291896498.8745.6.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2561 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755220Ab0LIMV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 07:21:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

This patch-series adds FCoE support to 57712 HW. It provides
required intefaces for upper-level driver (CNIC) and handles
FCoE related HW/FW initialization and flows.

Please consider applying the series to net-next after
applying patch-series with fixes from Vlad Zolotarov
which updates version to 1.60.00-7 (otherwise version
update patch can't be applied)

Since the FW files are too big and will not pass through
the mailing list, it is also located at:
http://linux.broadcom.com/eilong/1.62.00-1


Thanks,
Dmitry



