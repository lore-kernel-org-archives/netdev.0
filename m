From: David Miller <davem@davemloft.net>
Subject: net-2.6 being rebased...
Date: Tue, 03 Jun 2008 14:24:07 -0700 (PDT)
Message-ID: <20080603.142407.08652094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linville@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60541
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750751AbYFCVYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 17:24:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Because of the bugs in Adam's MD5/SACK fix I need to rebase
the tree to get rid of it.  Adam, please post a complete
new patch once you've fixed that SACK option adding problem.
Thanks.


The only other local change in net-2.6 is Dave Young's bluetooth
deadlock fix which I'll put into the rebased tree.

I hate to do this but:

1) I didn't pull any of this into net-next-2.6 yet, so it
   hasn't propagated there.

2) I don't want Adam's buggy change holding back my ability
   to push bug fixes to Linus.

Sorry, but it's necessary.

I'll post a reply to this after the rebase is complete.
