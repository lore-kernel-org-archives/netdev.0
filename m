From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: pci_function_reset from driver
Date: Thu, 28 Oct 2010 13:52:38 -0500
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA6E4952D6BD@MNEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:24394 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757434Ab0J1S5J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 14:57:09 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

For FLR supported  device can I issue FLR on that 
device from the driver ?

For example in kdump case it is recommended to reset 
the device after loading of crash kernel.Can we issue FLR
from driver in such case(call some function like pci_reset_function).

Rajesh


