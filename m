From: David Miller <davem@davemloft.net>
Subject: net-2.6.22 rebased...
Date: Mon, 26 Mar 2007 01:22:49 -0700 (PDT)
Message-ID: <20070326.012249.123921409.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40905
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933669AbXCZIWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 04:22:51 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 028ABAE4297
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2007 01:22:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I build this tree by cloning the current bug fix net-2.6 tree
then merging in all of the net-2.6.22 stuff on top, in the
usual spot:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.22.git

I merged in a few of the small "oh shit" type bug fix patches
into the changeset that caused the problem.

There were also, as usual, several merge conflicts.

I double and triple checked my work, but it's always possible
that I made mistakes here, so let me know if you see anything
out of place or flat-out wrong.

Sanity tested on ix86, and I'm doing build+sanity checks on
sparc64 and have a "allmodconfig" build going as well.

Thanks!
