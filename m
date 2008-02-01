From: David Miller <davem@davemloft.net>
Subject: "no new features"...
Date: Thu, 31 Jan 2008 19:46:44 -0800 (PST)
Message-ID: <20080131.194644.03127203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43368
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753686AbYBADqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 22:46:23 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DE607C8C220
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 19:46:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've just sent a pull request to Linus for net-2.6 and that should
effectively be my final feature merge to him.

Outside of the 6-patch thing Arnaldo is respinning I am calling for no
new stuff to go in at this time.  Only bug fixes.

We've merged a lot of stuff already (on the order of 1800 patches in
total).  So we should draw the line in the sand so that we can have
some hope to fix the almost guarenteed bugs.

Many folks, including Linus, are flying home this weekend.

So my basic plan is to open up a net-2.6.26 tree about a week and a
half from now.

Please set your feature work aside for the moment and find a fun
bug to fix instead. :-)

Thanks!

