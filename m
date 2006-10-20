From: Tino Keitel <tino.keitel@tikei.de>
Subject: wake on LAN with sky2
Date: Sat, 21 Oct 2006 00:24:00 +0200
Message-ID: <20061020222400.GA32616@dose.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:14480 "EHLO
	eazy.amigager.de") by vger.kernel.org with ESMTP id S2992739AbWJTWYE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 18:24:04 -0400
Received: from dose.home.local (port-212-202-201-86.dynamic.qsc.de [212.202.201.86])
	by eazy.amigager.de (Postfix) with ESMTP id EDA0B25C1F0
	for <netdev@vger.kernel.org>; Sat, 21 Oct 2006 00:24:01 +0200 (CEST)
Received: from scorpion by dose.home.local with local (Exim 4.63)
	(envelope-from <tino.keitel@tikei.de>)
	id 1Gb2mW-0008UG-8B
	for netdev@vger.kernel.org; Sat, 21 Oct 2006 00:24:00 +0200
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,

I saw that the wake on LAN function was removed from sky2 in kernel
2.6.17. It was also mentioned that this happened because it didn't work
and also couldn't be tested but that it will be put back later.

Is there some progress regarding this? I have a Mac mini core duo that
can do suspend to RAM so that wake on LAN can be used to wake it up
again, at least with MacOS X. I would be happy to help testing this
with the sky2 driver.

Regards,
Tino
