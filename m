From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: SR-IOV PCI quirk for 82599?
Date: Fri, 14 May 2010 16:26:02 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E70B078DCA0@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:8920 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240Ab0ENQ1t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 12:27:49 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a PCI quirk for the 82576 controller that programs the PCI BARs to use Flash memory if the BIOS has not allocated resources for the SR-IOV VF BARs.

Is there a similar quirk for the 82599, or can even the same one be used for that device?

Thanks,
Anna 
