From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/3] isdn: patches for 2.6.31
Date: Sun, 31 May 2009 01:32:04 +0200 (CEST)
Message-ID: <20090531-patch-00.tilman@imap.cc>
To: davem@davemloft.net, Karsten Keil <karsten-keil@t-online.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-ker
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:41625 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752295AbZE3XcQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 May 2009 19:32:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, Karsten,

I would like to propose the following three patches to the Kernel CAPI
subsystem for inclusion in kernel release 2.6.31.
The first one was proposed four weeks ago and so far hasn't met any
protests.
The second one is a rather trivial bugfix and documentation improvement.
The third one just adds a few new insights about the workings of the
CAPI subsystem to the Documentation file, INTERFACE.CAPI.

Thanks,
Tilman
