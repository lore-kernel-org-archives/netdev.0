From: David Miller <davem@davemloft.net>
Subject: net-2.6.22 rebased and tcp-2.6 created
Date: Thu, 12 Apr 2007 12:36:32 -0700 (PDT)
Message-ID: <20070412.123632.31662053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39050
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752024AbXDLTgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 15:36:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id EF400AB437A
	for <netdev@vger.kernel.org>; Thu, 12 Apr 2007 12:36:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok, as promised:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.22.git
	kernel.org:/pub/scm/linux/kernel/git/davem/tcp-2.6.git

Basically, the tcp-2.6 tree is the net-2.6.22 tree with the TCP
RB-tree based work added.

I'll start working on my huge patch backlog this afternoon, feel free
to add to it :-)))
