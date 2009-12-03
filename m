From: David Miller <davem@davemloft.net>
Subject: README: net-next-2.6 plans...
Date: Wed, 02 Dec 2009 23:01:42 -0800 (PST)
Message-ID: <20091202.230142.199015015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54395
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751694AbZLCHBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 02:01:35 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7872624C5C5
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2009 23:01:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


2.6.32 has been released.

This means the merge window is about to open.

The merge window is about merging existing work to Linus.

Therefore, it is not about merging new things into subsystem
maintainer trees like mine. :-)

If it doesn't reach my inbox by tomorrow afternoon (PST timezone) then
it had better be a bug fix of some kind :-)

The only exceptions are the two suspend/resume patches I've asked
Oliver to respin for usbnet/cdc-ether.  He submitted those a long
time ago and he just needs to make them apply cleanly to the current
net-next-2.6

I plan to push twice to Linus.  Once to get all the new features to
him, and then a smaller "cleanup" push a few days later to fix any
major bustage the net-next-2.6 tree introduces.

Once 2.6.33-rc1 is out, I will cut a new net-next-2.6 tree.

Thanks in advance for your understanding and cooperation.
