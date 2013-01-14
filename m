From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 0/10] bnx2x: patch series
Date: Mon, 14 Jan 2013 17:11:40 +0200
Message-ID: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1173 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757209Ab3ANQJz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 11:09:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains several patches, some of which 
are cosmetic (e.g., introduce 2013),
some fix small issues or rare corner cases (e.g., link failure in self test),
and some add new functionality - better support for dumping our registers 
(supporting `ethtool -w/-d') and support for FW GRO in bridging scenarios.

Please consider applying this patch-series to 'net-next'.

Thanks,
Yuval Mintz
