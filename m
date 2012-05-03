From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] Sometimes the ISDN chip only controls the D-channel
Date: Thu, 03 May 2012 04:08:27 -0400 (EDT)
Message-ID: <20120503.040827.1676148884337744047.davem@davemloft.net>
References: <4FA2265D.6040000@linux-pingi.de>
	<20120503.025059.1771068683530938115.davem@davemloft.net>
	<4FA23438.6090103@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab2ECIIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 04:08:34 -0400
In-Reply-To: <4FA23438.6090103@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Thu, 03 May 2012 09:31:04 +0200

> PCM only mode need a special protocol and a mechanism to set/get/store
> the PCM slots of the card, and this is for what the extra stuff is used.

It changed the values of some macros which are actually used by the
code.

Then it adds members to structures, and defines, which are completely
unused.

The latter part is completely bogus.

This is the second time I'm saying this again.  I'm not saying it
a third time, instead I'll just ignore you.
