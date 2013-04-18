From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 0/2] bnx2x: Bug fixes patch series
Date: Thu, 18 Apr 2013 11:49:04 +0300
Message-ID: <1366274946-11625-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3721 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756814Ab3DRJv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 05:51:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch contain fixes in two areas -

  1. Preventing UNDI FW from illegally accessing memory when it shouldn't.

  2. Fix interrupt coalescing initialization and configuration when working
     with multiple CoS.

Please consider applying these patches to `net'.

Thanks,
Yuval Mintz
