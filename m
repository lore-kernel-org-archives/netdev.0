From: David Miller <davem@davemloft.net>
Subject: net-2.6.22 and tcp-2.6 rebased...
Date: Fri, 20 Apr 2007 23:47:33 -0700 (PDT)
Message-ID: <20070420.234733.50322125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linville@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42104
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932943AbXDUGrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2007 02:47:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It was a multi-day uphill battle but I got it done just
now.

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.22.git
	kernel.org:/pub/scm/linux/kernel/git/davem/tcp-2.6.git

As before, tcp-2.6.git is net-2.6.22 cloned with the TCP RB-Tree
work added.

An allmodconfig build went ok for me on sparc64, and I'm about
to reboot my workstation into the tcp-2.6 tree to give that
some basic sanity checks.

Andrew, I know you're still majorly backlogged but this is just
a heads up that I've rebased.  I even had conflicts with
Linus's tree as he checked things in about a half hour ago
but it should go all clean now against his current tree.

John, would love to see those wireless patches soon :-)
