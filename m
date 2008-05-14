From: David Miller <davem@davemloft.net>
Subject: some netdev merges coming...
Date: Wed, 14 May 2008 04:52:39 -0700 (PDT)
Message-ID: <20080514.045239.34646782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753183AbYENLwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 07:52:45 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0C9AFC8C1F2
	for <netdev@vger.kernel.org>; Wed, 14 May 2008 04:52:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Once all of the pending bug fixes in net-2.6 make their way to Linus's
tree.  I plan to do some merging.

First, I'll pull Linus's tree into net-2.6 This will be the base for
future bug fixes, as usual.

Next, I'll pull net-2.6 into net-next-2.6

I got distracted today by some bugs and therefore didn't process
as many patches in my backlog as I would have liked to.  I hope
to make up for that tomorrow after I do the merging.
