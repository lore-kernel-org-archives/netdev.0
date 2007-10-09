From: David Miller <davem@davemloft.net>
Subject: net-2.6.24 rebased...
Date: Tue, 09 Oct 2007 02:41:08 -0700 (PDT)
Message-ID: <20071009.024108.59465259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51809
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751422AbXJIJlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 05:41:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The TCP bug fix that went into Linus's tree today created some
conflicts with net-2.6.24, so I rebased:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.24.git

I took the opportunity to integrate fix patches into the patches which
introduced those bugs or build failures.

BTW, when the tree gets this big I tend to move the pre-rebase tree
to:

	kernel.org:/pub/scm/linux/kernel/git/davem/bak-net-2.6.24.git

It can be useful if a mistake is made during a rebase and we need
to figure out what happened.

9.1MB, 739 changesets, keep those patches flowing!

Enjoy
