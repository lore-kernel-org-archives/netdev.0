From: David Miller <davem@davemloft.net>
Subject: net-next-2.6 plans...
Date: Thu, 17 Jul 2008 21:32:22 -0700 (PDT)
Message-ID: <20080717.213222.98349149.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37475
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750890AbYGREcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 00:32:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 63511C8C1D3
	for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 21:32:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Tonight I'm going to make sure all the stuff that went into the merge
window works on my primary test machines.

Then I'm going to merge Linus's current tree into net-next-2.6 and
move it over to net-2.6

net-next-2.6 will become a fresh clone of Linus's tree and clean for
the time being.  After the merge window is closed I'll get it as close
to Linus's tree as possible then start accepting changes for the
next merge window.  But that's such a long ways off, I'd not think
about it even for now :-)
