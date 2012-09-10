From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH 0/7] bnx2x: bug fixes for net
Date: Mon, 10 Sep 2012 18:48:48 +0300
Message-ID: <1347292135-30250-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1635 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754372Ab2IJQNI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 12:13:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains various bug fixes for the bnx2x driver -
about half of them are link related, while the other either add
code missing in previous git commits or fix erroneous flows.

Please consider applying this patch series to 'net'.

Thanks,
Yuval Mintz
