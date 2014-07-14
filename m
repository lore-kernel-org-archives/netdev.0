From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 0/2] sfc: Add 40G support
Date: Mon, 14 Jul 2014 08:37:06 +0100
Message-ID: <53C388A2.5040705@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:3991 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751899AbaGNHuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 03:50:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for Solarflare 7000 series
40G Solarflare network adapters starting with the SFN7X42Q. 

Edward Cree (1):
  sfc: Add 40G link capability decoding

Mateusz Wrzesinski (1):
  sfc: Adding PCI ID for Solarflare 7000 series 40G network adapter.

 drivers/net/ethernet/sfc/efx.c       |  2 ++
 drivers/net/ethernet/sfc/mcdi_port.c | 11 +++++++++++
 2 files changed, 13 insertions(+)
