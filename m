From: David Miller <davem@davemloft.net>
Subject: dealing with Jeff's absense...
Date: Wed, 08 Oct 2008 14:38:47 -0700 (PDT)
Message-ID: <20081008.143847.87780558.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38759
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754371AbYJHVjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 17:39:11 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5C707C8C188
	for <netdev@vger.kernel.org>; Wed,  8 Oct 2008 14:38:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I am finally caught up enough with my own assigned patches
that I think I can take a stab at dealing with the jgarzik
backlog.

I'm going to pull Linus's tree into net-2.6, and then pull
net-2.6 into net-next-2.6 and then start trying to sort out
all of the patchwork patches assigned to Jeff.

I even need to do some of this to get to some of my own
patches, such as the DSA stuff from Lennert, since those
depend upon some phylib bits.
