From: David Miller <davem@davemloft.net>
Subject: 2.6.19 status
Date: Thu, 28 Sep 2006 18:41:35 -0700 (PDT)
Message-ID: <20060928.184135.41635707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36506
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751245AbWI2Blh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 21:41:37 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 17E6BAE424A
	for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 18:41:36 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've just pushed my current net-2.6 tree to Linus.  The bulk of the
changes in there are endianness annotations for sparse by Al Viro,
along with the patches I've been ACK'ing here on the list and
elsewhere.

If you want a non-bugfix change to get into 2.6.19 you must have it to
me by the end of the weekend.

As of next Monday, anything I receive has to be a bugfix for 2.6.19
consideration.

Thanks for everyone's hard work and let's make sure there are no
networking regressions at all in 2.6.19, in fact let's strive to
make it have no regressions plus bugs fixed that were in 2.6.18 :-)
