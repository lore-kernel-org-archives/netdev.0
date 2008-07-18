From: David Miller <davem@davemloft.net>
Subject: READ ME, net-2.6 fully merged
Date: Fri, 18 Jul 2008 03:39:47 -0700 (PDT)
Message-ID: <20080718.033947.193705552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52614
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757259AbYGRKjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 06:39:48 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B0657C8C187
	for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 03:39:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I merged Linus's current tree into net-next-2.6, fixed up all
the merge conflicts, and pushed this out as plain "net-2.6":

	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

There is a net-next-2.6 still there, but it's just a plain clone
of Linus's tree so that the linux-next folks can still do dummy
pulls from it.

I'll work through my backlog and the TX multiqueue issues Patrick
brought up yesterday.
