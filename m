From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 0/6] bnx2x: Bug fixes patch series
Date: Mon, 23 Sep 2013 10:12:49 +0300
Message-ID: <1379920375-10303-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4679 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994Ab3IWHNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 03:13:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch contains various bug fixes, half of which are SR-IOV related
(some fixing issues in the recently added VF RSS support), while the other fix
a wide assortments of issues in the driver.

Please consider applying these patches to `net'.

Thanks,
Yuval Mintz
