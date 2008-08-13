From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 00/25] bnx2x: Bug Fixes
Date: Wed, 13 Aug 2008 17:11:37 +0300
Message-ID: <1218636697.547.74.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yanivr@broadcom.com>,
	"Yitchak Gertner" <gertner@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3193 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202AbYHMOMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:12:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These patches contain bug fixes for the bnx2x driver. Please consider
applying.

Thanks,
Eilon

01 - FW (bootcode) interface fixes
02 - Not dropping packets with L3/L4 checksum error
03 - Statistics
04 - FW Internal Memory structure
05 - Load/Unload under traffic
06 - HW lock mechanism
07 - HW attention lock
08 - Memory allocation
09 - Self-test false positive
10 - PBA Table Page Alignment Workaround
11 - Delay in while loops
12 - Clearing MAC addresses filters
13 - WoL capability
14 - Wrong structure size
15 - No LRO without Rx checksum
16 - Link order with external PHY
17 - Pause settings
18 - Change GPIO for any port
19 - 8073 PHY changes
20 - 1G LED does not turn off
21 - Driver info
22 - Minor code improvements
23 - Spelling mistakes
24 - checkpatch compliance
25 - Version



