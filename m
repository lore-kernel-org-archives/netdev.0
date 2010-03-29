From: <denis@nano-net.ro>
Subject: Receive Packet Steering  patch - help.
Date: Tue, 30 Mar 2010 02:02:54 +0300
Message-ID: <52c61e4e796561ec02041286c968ca8a@mail.nano-net.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org, therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 89.46.17.122.nano-net.ro ([89.46.17.122]:48448 "EHLO
	MonServ.nano-net.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752272Ab0C2XYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 19:24:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


hi.
this patch seems to be a great ideea, but when trying to apply the patch to
kernel 2.6.33.1 it gives the following output:

linux-2.6.33.1 # cat ../rps_patch1.diff | patch -p1
patching file include/linux/netdevice.h
Hunk #1 succeeded at 844 (offset 86 lines).
Hunk #2 succeeded at 1281 (offset 108 lines).
Hunk #3 succeeded at 1323 with fuzz 2 (offset 134 lines).
Hunk #4 succeeded at 1590 with fuzz 2 (offset 136 lines).
patching file net/Kconfig
Hunk #1 succeeded at 45 (offset 20 lines).
patching file net/core/dev.c
patch: **** malformed patch at line 112: old backlog weight */

what am i doing wrong?

thanks

