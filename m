From: David Miller <davem@davemloft.net>
Subject: GIT tree updates...
Date: Sun, 28 Dec 2008 20:06:53 -0800 (PST)
Message-ID: <20081228.200653.129296720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51924
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751404AbYL2EGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2008 23:06:50 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3C9A5C8C17F
	for <netdev@vger.kernel.org>; Sun, 28 Dec 2008 20:06:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First, I want to thank everyone for all of their hard work on the
changes that went into net-next-2.6

Next, since Linus pulled in my net-next-2.6 tree earlier today I'm
resetting both net-2.6 and net-next-2.6

net-next-2.6 will just be a dumb clone, so that Stephen Rothwell has a
dummy empty tree to pull from for his -next tree.  I want to see no
patches meant for 2.6.30 at this time.

net-2.6 is where work will commence, and this means we are only doing
bug fixes and non-intrusive simple cleanups.

If you push the limits of these liberal rules for patches, and we get
burnt by this, you will pay.  I am warning everyone now. :-)
