From: David Miller <davem@davemloft.net>
Subject: net-tx-2.6 GIT tree
Date: Mon, 23 Jun 2008 20:51:06 -0700 (PDT)
Message-ID: <20080623.205106.159594562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46951
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753308AbYFXDvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 23:51:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2C233C8C1B6
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 20:51:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've created:

	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-tx-2.6.git

For the TX packet queueing overhaul.  It is a clone of
net-next-2.6

Currently the TG3 and NIU TX backlog patch sets are checked into
there.
