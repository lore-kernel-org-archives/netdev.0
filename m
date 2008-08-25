From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 0/9] bnx2x: Bug Fixes
Date: Mon, 25 Aug 2008 17:24:18 +0300
Message-ID: <1219674258.19456.26.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yitchak Gertner" <yitchak.gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3159 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754140AbYHYOZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 10:25:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These patches contain bug fixes for the bnx2x driver. Please consider
applying.

Thanks,
Eilon

1 - Rx work check
2 - Fan failure mechanism on additional design
3 - Minimize lock time
4 - HW lock timeout
5 - Initialization structure
6 - NIC load failure cleanup
7 - NAPI and interrupts enable/disable
8 - Multi Queue
9 - Version update



