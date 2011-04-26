From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/4] Minor ipv4 routing cleanups.
Date: Tue, 26 Apr 2011 15:11:57 -0700 (PDT)
Message-ID: <20110426.151157.102541615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48340
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758448Ab1DZWMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 18:12:30 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 54BDB24C088
	for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 15:11:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just a few cleanups and simplifications I came across while
auditing some aspects of the ipv4 routing code.

I'm going to do some more testing and validation on these changes
before I actually push them out to net-next-2.6

Signed-off-by: David S. Miller <davem@davemloft.net>
