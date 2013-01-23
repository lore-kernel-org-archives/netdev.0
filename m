From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 0/12] bnx2x: patch series
Date: Wed, 23 Jan 2013 15:21:42 +0200
Message-ID: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1744 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755851Ab3AWOWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 09:22:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contain several Semi-semantic patches (i.e., some are purely
semantic, such as correcting comments & typos, while others slightly change the
bnx2x code without effectively changing any flow), while other fix several small
issues, mostly either memory-related or missing segments from our recent SR-IOV
submission.

Please consider applying this patch-series to 'net-next'.

Thanks,
Yuval Mintz
