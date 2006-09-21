From: Zang Roy-r61911 <tie-fei.zang@freescale.com>
Subject: [patch 0/3 v2] Add tsi108 On chip Ethernet device driver support
Date: 21 Sep 2006 12:04:03 +0800
Message-ID: <1158811443.10823.40.camel@localhost.localdomain>
References: <A0CDBA58F226D911B202000BDBAD46730A1B1410@zch01exm23.fsl.freescale.net>
	 <1157962200.10526.10.camel@localhost.localdomain>
	 <1158051315.14448.91.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:29382 "EHLO
	de01egw02.freescale.net") by vger.kernel.org with ESMTP
	id S1751193AbWIUEEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 00:04:15 -0400
To: jgarzik <jgarzik@pobox.com>
In-Reply-To: <1158051315.14448.91.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Tundra Semiconductor Corporation (Tundra) Tsi108/9 is a host bridge
for PowerPC processors that offers numerous system interconnect options
for embedded application designers . The Tsi108/9 can interconnect 60x
or MPX processors to PCI/X peripherals, DDR2-400 memory, Gigabit
Ethernet, and Flash.

Tsi108/109 is used on powerpc/mpc7448hpc2 platform.

The following serial patches provide Tsi108/9 on chip Ethernet chip
support.

1/3 : Config and Makefile modification.
2/3 : Header file
3/3 : C body file

This serial patches fix the issues in the feedback from the previous
patches.
Feedback is welcomed.
Roy 

