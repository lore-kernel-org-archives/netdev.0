From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net-next 0/6] bnx2x: new features patch series
Date: Mon, 23 Dec 2013 20:44:37 +0200
Message-ID: <1387824283-15687-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:56974 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757625Ab3LWSot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 13:44:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series adds/fixes several new features in the bnx2x driver -
it adds support for loading the bnx2x over an UNDI running on a Multi-function
device, adds missing bits for PCIe AER support and enables VFs to properly
configure multicast filters
(In addition, it also contains some small improvements in driver behaviour).

Please consider applying these patches to `net-next'.

Thanks,
Yuval Mintz
