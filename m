From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 0/5] bnx2x: Enhancements patch series
Date: Wed, 24 Apr 2013 14:44:57 +0300
Message-ID: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3478 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178Ab3DXMqW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 08:46:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains several enhancements, as well as small fixes:

  - Patch [1/5] - Prevent a theoretical problem in our GRO implementation.

  - Patch [2/5] - Support Rx/Tx pause control configuration in autoneg.

  - Patch [3/5] - Enhance support for VF's MAC setting and removal.

  - Patch [4/5] - Fix a small memory leak between bnx2x and cnic.

  - Patch [5/5] - Allow bnx2x to recover after a second slot reset.

Please consider applying these patches to `net-next'.

Thanks,
Yuval Mintz
