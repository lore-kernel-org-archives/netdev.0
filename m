From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH v2 0/7] bnx2x: bug fixes for net
Date: Tue, 11 Sep 2012 17:34:07 +0300
Message-ID: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4183 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759506Ab2IKO6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 10:58:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains various bug fixes for the bnx2x driver -
about half of them are link related, while the other either add
code missing in previous git commits or fix erroneous flows.

Changes from v1:
----------------
  -  Patch 06/07 - update returned version to 1 (from 0), when changing
     the registered dumped. Corrected patch description.

Please consider applying this patch series to 'net'.

Thanks,
Yuval Mintz
