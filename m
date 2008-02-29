From: David Miller <davem@davemloft.net>
Subject: net-2.6.26 work commences...
Date: Thu, 28 Feb 2008 20:43:48 -0800 (PST)
Message-ID: <20080228.204348.49768650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754496AbYB2Ens (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 23:43:48 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1231DC8C1F2
	for <netdev@vger.kernel.org>; Thu, 28 Feb 2008 20:43:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've freshened up my net-2.6.26 tree to be a clone of
the current state of the net-2.6 one.  And I will start
applying patches to it now:

	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.26.git

I want to thank everyone for not getting too distracted over the past
few weeks, and actively fixing the bugs that have been reported.
