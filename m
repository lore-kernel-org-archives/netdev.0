From: David Miller <davem@davemloft.net>
Subject: net-2.6.20 is up...
Date: Wed, 08 Nov 2006 00:34:38 -0800 (PST)
Message-ID: <20061108.003438.84977197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11684
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1754431AbWKHIeg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 03:34:36 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


At:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

I've integrated a series of endianness annotations from Al
Viro to start things off.

I have some things to review in my queue which I'll work on
putting in there including:

1) Stephen Hemminger's netpoll queueing cleanups and fixes

2) The pending IPV6 tunnel work by Ville Nuorvala discussed
   last week.  I have to review that thread carefully as
   I think there are some semantic issues with those changes
   which need to be fixed up first.

3) Stephen Hemminger's socket based congestion control selection
   semantic patches.

There are some other small miscellaneous patches in my queue
too, like an SCTP warning fix and stuff like that.

Feel free to queue 2.6.20 networking stuff to me.

Thanks.
