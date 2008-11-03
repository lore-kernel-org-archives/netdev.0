From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 0/4]bnx2x: bug fixes
Date: Mon, 03 Nov 2008 18:10:57 +0200
Message-ID: <1225728657.14568.9.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3896 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755690AbYKCQLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 11:11:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I'm sending this patch to the net-2.6 and not the net-next since it
contains bug fixes that I believe should be address. Please let me know
if you think otherwise.

0001 Removing the PMF indication when unloading
0002 PCI configuration bug on big-endian
0003 Calling netif_carrier_off at the end of the probe
0004 Version Update

Thanks,
Eilon



