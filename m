From: David Miller <davem@davemloft.net>
Subject: net-2.6 and net-2.6.26 merged
Date: Tue, 18 Mar 2008 00:52:25 -0700 (PDT)
Message-ID: <20080318.005225.50500035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45891
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751530AbYCRHwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 03:52:09 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 96D0EC8C234
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 00:52:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As I eluded to in a reply I just made to John Linville
wrt. wireless merging, I did a lot of upstream
pulling into my trees.

I pulled Linus's current tree into net-2.6

Next, I pulled net-2.6 into the net-2.6.26 tree and
resolved all conflicts.  I did an "allmodconfig" build
on sparc64 and that went without any build errors.
