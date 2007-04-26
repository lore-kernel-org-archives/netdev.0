From: David Miller <davem@davemloft.net>
Subject: net and tcp GIT trees rebased
Date: Thu, 26 Apr 2007 01:52:35 -0700 (PDT)
Message-ID: <20070426.015235.26277968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50570
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933701AbXDZIw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:52:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


With the 2.6.21 release, I've rebased the two development
trees:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
	kernel.org:/pub/scm/linux/kernel/git/davem/tcp-2.6.git

Note that net-2.6.22.git has been thus renamed to net-2.6.git
since this will be merged to Linus.

I integrated a bunch of patches from Andrew Morton and
others right after rebasing.

The only big thing I expect pending is a re-cut RXRPC patch set from
David Howells.

I still have some backlog to process, as usual.

Enjoy.
