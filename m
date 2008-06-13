From: David Miller <davem@davemloft.net>
Subject: tree plans...
Date: Thu, 12 Jun 2008 21:21:58 -0700 (PDT)
Message-ID: <20080612.212158.128920282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35438
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750992AbYFMEV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 00:21:58 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0DC10C8C0DD
	for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 21:21:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Once Linus takes the pull request I just sent out I plan to merge:

	Linus --> net-2.6 --> net-next-2.6

At which time I'll likely work on a few pending items such as making
proto->destruct return void and elimination of the sk_callback_lock.

Meanwhile I'll try to make some more progress with the WEXT compat
handling patch set I've been working on.
