From: David Miller <davem@davemloft.net>
Subject: GIT tree plans...
Date: Mon, 01 Dec 2008 23:21:24 -0800 (PST)
Message-ID: <20081201.232124.30567891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56492
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751037AbYLBHVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 02:21:23 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9A13FC8C180
	for <netdev@vger.kernel.org>; Mon,  1 Dec 2008 23:21:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There are a bunch of conflicts to resolve in the net-next-2.6
tree because of things in Linus's tree.

So what I'm going to do is wait for Linus to take in the
net-2.6 pull request I just sent to him.  And afterwards
do all the necessary merges and conflict resolution to
get everything clean again.

Meanwhile I'll purge as much of the pending net-next-2.6
patch queue items as I can.

Just FYI...
