From: Suman Tripathi <stripathi@apm.com>
Subject: [PATCH net-next v1 0/1]drivers: net: xgene: Fix the ACPI support for RGMII/SGMII0/XFI ethernet interfaces of APM X-Gene SoC.
Date: Wed, 24 Jun 2015 13:51:39 +0530
Message-ID: <1435134100-12460-1-git-send-email-stripathi@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, kchudgar@apm.com,
	patches@apm.com, isubramanian@apm.com,
	Suman Tripathi <stripathi@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from denmail01-v4020.amcc.com ([192.195.68.30]:33822 "EHLO
	denmail01.amcc.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750847AbbFXIW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 04:22:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1 change:
 * Fix the compilation error.
 * Drop other patches as it got accepted.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Suman Tripathi <stripathi@apm.com>
---

Suman Tripathi (1):
  drivers: net: xgene: Fix the compilation error "error: implicit
    declaration of function 'acpi_evaluate_integer'" in APM X-Gene
    ethernet driver.

 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 ++
 1 file changed, 2 insertions(+)

--
1.8.2.1
