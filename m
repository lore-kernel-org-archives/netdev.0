From: Achim Frase <achim.frase@googlemail.com>
Subject: RTL8111 PCI Express Gigabit driver r8169 produces slow file
	transfers
Date: Thu, 27 Sep 2007 15:14:01 +0200
Message-ID: <1190898841.7919.14.camel@BeeB1t>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:43835 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754244AbXI0NOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 09:14:08 -0400
Received: by ug-out-1314.google.com with SMTP id z38so1299801ugc
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2007 06:14:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Linux r8169 crew,

I have got your e-mail address from the modinfo of the r8196 module.

I am not sure if this is the right way to contact you, but I hope you
could help me.

The current driver in Kernel 2.6.22 produces very bad network speeds.
I only geht 100 kb/s.

Maybe you could take a look at this bug-report at launchpad.net.

https://bugs.launchpad.net/ubuntu/+source/linux-ubuntu-modules-2.6.22/+bug/114171

The latest driver from realtek is working very well.
ftp://210.51.181.211/cn/nic/r8168-8.003.00.tar.bz2

What I would like to know, is, if the latest realtek driver will make it
into the kernel, or if the problems with the r8196 module are already
solved.

If there are any questions feel free to contact me.

Thanks in Advanced

Achim Frase

