From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next PATCH 0/5] Energy Efficient Ethernet patch series
Date: Mon, 10 Sep 2012 18:51:03 +0300
Message-ID: <1347292268-30348-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3497 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754372Ab2IJQPX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 12:15:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains various EEE changes, the most significant being
the addition of EEE support for devices with 4-ports, as well as replacing the
auto-grEEEn feature with native EEE (802.3az) for boards with 54618SE phys.

Please consider applying this patch series to 'net-next'.

Thanks,
Yuval Mintz
