From: Nicolae Rosia <nicolae.rosia@certsign.ro>
Subject: macb: zynq: why is SG disabled?
Date: Wed, 1 Jul 2015 18:14:43 +0300
Message-ID: <559403E3.3050900@certsign.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: Michal Simek <michal.simek@xilinx.com>,
	Punnaiah Choudary Kalluri
	<punnaiah.choudary.kalluri@xilinx.com>, <netdev@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Michal Simek <michal.simek@xilinx.com>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.uti.ro ([91.220.13.110]:55983 "EHLO mx2.uti.ro"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754275AbbGAPQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2015 11:16:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

After reading the GEM part of Zynq7000 Technical Reference Manual [0], I 
think that SG should be supported.
Is there a reason why SG is disabled in macb for Zynq?

Best regards,
Nicolae Rosia
