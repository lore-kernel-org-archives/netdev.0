From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 0/4] bnx2x: Bug fixes patch series
Date: Sun, 17 Nov 2013 08:59:25 +0200
Message-ID: <1384671569-30105-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, dmitry@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4174 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230Ab3KQG7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Nov 2013 01:59:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains several fixes, relating either to SR-IOV flows
or to critical sections protected by the rtnl lock.

Please consider applying these patches to `net'.

Thanks,
Yuval Mintz
