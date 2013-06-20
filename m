From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 0/4] bnx2x: enhancement patch series
Date: Thu, 20 Jun 2013 17:39:07 +0300
Message-ID: <1371739151-15744-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4974 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757569Ab3FTOjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 10:39:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series mostly revolves around improving SR-IOV implementation
(Better PF-VF relation, sanity checks and timings), as well as including
a patch correcting the (outward) advertisement of 20G capabilities.

Please consider applying these patches to `net-next'.

Thanks,
Yuval Mintz
