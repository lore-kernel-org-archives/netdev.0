From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 0/6] bnx2x: link patch series
Date: Wed, 20 Jun 2012 11:49:29 +0300
Message-ID: <1340182175-916-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1813 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752459Ab2FTIvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:51:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series change bnx2x's link code. It contains both
semantic cleanup of the code as well as several patches that
add new support for optical modules - better 1G SFP support,
SFP+ Tx Fault support and implementation of the new ethtool API
for accessing the module's eeprom (on the bnx2x side).

Please consider applying this patch-series to 'net-next'.

Thanks,
Yuval Mintz
