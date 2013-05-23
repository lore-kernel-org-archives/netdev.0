From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH v2 net-next 0/4] bnx2x: Enhancement patch series
Date: Thu, 23 May 2013 10:21:48 +0300
Message-ID: <1369293712-26541-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2837 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440Ab3EWHWf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 03:22:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contain several small enhancements - chief among those are
the implementation of ethtool's private flags callback to share information
about the storage offload capabilities of its network interfaces,
and the prevention of a link flap when booting from storage area networks.

Please consider applying these patches to `net-next'.

Changes from V1:
  - Patch 1, removed trailing whitespaces from private flag strings.

Thanks,
Yuval Mintz
