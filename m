From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 00/13] bnx2x: net-next patch series
Date: Sun, 2 Dec 2012 16:05:44 +0200
Message-ID: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2490 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752061Ab2LBOFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains several small changes to the bnx2x driver,
including dcb changes, graceful error handling and benign error masking,
and setting the driver's configuration according to management/nvram
held values.

Please consider applying these patches to 'net-next'.

Thanks,
Yuval Mintz
