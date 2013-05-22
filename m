From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 0/4] bnx2x: Enhancement patch series
Date: Wed, 22 May 2013 15:22:35 +0300
Message-ID: <1369225359-5578-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2004 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456Ab3EVMUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 08:20:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contain several small enhancements - chief among those are
the implementation of ethtool's private flags callback to share information
about the storage offload capabilities of its network interfaces,
and the prevention of a link flap when booting from storage area networks.

Please consider applying these patches to `net-next'.

Thanks,
Yuval Mintz
