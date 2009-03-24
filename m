From: David Miller <davem@davemloft.net>
Subject: The Plan
Date: Tue, 24 Mar 2009 15:35:06 -0700 (PDT)
Message-ID: <20090324.153506.44330862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45154
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750771AbZCXWfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 18:35:18 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7CCF735C12E
	for <netdev@vger.kernel.org>; Tue, 24 Mar 2009 15:35:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Everything in net-2.6 right now, as well as the final fix
we come up with for the GRO issue will get sucked into
net-next-2.6 as well as queued up for -stable.

Everything in patchwork right now will either be merged
into net-next-2.6 or tossed.

I'll likely send my pull request to Linus tomorrow.

Once that goes in, both net-2.6 and net-next-2.6 will become
fresh clones of Linus's tree.
