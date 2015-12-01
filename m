From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH 0/2 net-next] ravb: More compat strings
Date: Tue,  1 Dec 2015 16:43:01 +0900
Message-ID: <1448955783-22806-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	devicetree@vger.kernel.org
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43193 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755002AbbLAHnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 02:43:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this short series adds generic gen2 and gen3, and soc-specific compat strings
for the missing gen2 SoCs.

Simon Horman (2):
  ravb: Add fallback compatibility strings
  ravb: Add device tree support for r8a779[123]

 Documentation/devicetree/bindings/net/renesas,ravb.txt | 14 ++++++++++++--
 drivers/net/ethernet/renesas/ravb_main.c               |  2 ++
 2 files changed, 14 insertions(+), 2 deletions(-)

-- 
2.1.4
