From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 0/9] bnx2x: patch series
Date: Mon, 18 Feb 2013 10:16:29 +0200
Message-ID: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4081 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757042Ab3BRJVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 04:21:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains several SR-IOV related patches -
it allows setting and querying the number of vfs via sysfs,
configuring and querying VFs via iproute2 callbacks and properly
implements for VFs only the ethtool ops which they can safely perform.

In addition, it also contains several small fixes of rare corner-cases.

Please consider applying this patch-series to 'net-next'.

Thanks,
Yuval Mintz
