From: David Miller <davem@davemloft.net>
Subject: merge status
Date: Thu, 26 Mar 2009 22:30:10 -0700 (PDT)
Message-ID: <20090326.223010.229731981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55591
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750850AbZC0FaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 01:30:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 768F8C8C21D
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 22:30:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Linus took my pull request and we're sorting out the
fallout :-)

I accidently missed Herbert's legacy GRO fix, but never
fear it's really there now and will be sent to him and
2.6.29.1 shortly.

Both net-2.6 and net-next-2.6 have been freshly recloned
from Linus's tree.

I'm going to work on the patchwork backlog, but you guys HAVE TO STOP
sending me new stuff, your changes need to be in my tree before the
merge window opens.

Do I have to be a complete prick about this to get people to comply?
Every merge window it's the same thing over and over "oh I'm sorry,
won't wait until the last moment this time" and then these same people
do it again.

I'll merge what's in there right now and what John Linville said
he wants to send to me.  But THAT IS IT.
