From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 0/9] bnx2x: Bug fixes patch series
Date: Tue, 15 Oct 2013 16:28:46 +0200
Message-ID: <1381847335-32662-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4405 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759122Ab3JOO3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 10:29:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains fixes for various flows - several SR-IOV issues
are fixed, ethtool callbacks (coalescing and register dump) are corrected,
null pointer dereference on error flows is prevented, etc.

Please consider applying this series to 'net'.

Thanks,
Yuval Mintz
