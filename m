From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH v2 net-next 0/6] bnx2x: new features patch series
Date: Thu, 26 Dec 2013 09:57:06 +0200
Message-ID: <1388044632-9172-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:47794 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab3LZH5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 02:57:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series adds/fixes several new features in the bnx2x driver -
it adds support for loading the bnx2x over an UNDI running on a Multi-function
device, adds missing bits for PCIe AER support and enables VFs to properly
configure multicast filters
(In addition, it also contains some small improvements in driver behaviour).

Please consider applying these patches to `net-next'.

Changes from previous versions
------------------------------
  v2:
     - Fixed comment typo in patch 4 (propogate --> propagate)

Thanks,
Yuval Mintz
