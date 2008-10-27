From: David Miller <davem@davemloft.net>
Subject: net-next-2.6...
Date: Mon, 27 Oct 2008 11:35:03 -0700 (PDT)
Message-ID: <20081027.113503.149366323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43447
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750717AbYJ0Sf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 14:35:26 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id EABF2C8C17E
	for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 11:35:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen Rothwell said earlier today that it's OK to "let it rip"
and allow new changes to start flowing into the linux-next tree.

So I'll likely get the net-next-2.6 going today.

First I'll cut the tree with a fresh clone of Linus's current stuff,
then add in all the things which are in the queue already (Neil's
routing cache hacks, Thomas Graf's cgroup work, the print_mac() %pX
bits, etc.)

As always you can get a good idea of what will be looked at and considered
by taking a look at the patchwork queue for netdev:

	http://patchwork.ozlabs.org/

I'll make another posting when the new tree is up and operational.

Thanks.
