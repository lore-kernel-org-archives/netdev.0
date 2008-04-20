From: David Miller <davem@davemloft.net>
Subject: New GIT net tree naming...
Date: Sat, 19 Apr 2008 17:35:10 -0700 (PDT)
Message-ID: <20080419.173510.257216556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43993
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754210AbYDTAfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 20:35:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Based upon feedback from Andrew and others I'm now starting
to use a new naming scheme for my GIT trees:

For changes against Linus's current tree:

   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

For development meant to be merged in the next merge
window we have:

   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git

Andrew/Stephen, let me know if this works for you.  This way
the tree names will never change.
