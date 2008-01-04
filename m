From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/0]: Cassini bug fixes.
Date: Fri, 04 Jan 2008 00:32:31 -0800 (PST)
Message-ID: <20080104.003231.127196736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panther@balabit.hu, bazsi@balabit.hu, hidden@sch.bme.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51621
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753793AbYADIvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 03:51:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Over the past day I've put together the following set of bug fixes for
the Cassini driver.

At least with my setup it appears to basically work fine, not leak
memory, and the SKB BUG messages go away too.

I'll be honest and say that I've devoted a couple days to this work,
and therefore I have to turn my attention back to other tasks.  As a
result, it means it will be some time before I can look seriously into
any feedback folks provide.  And for that I apologize, but this
already consumed too much of my time.

I'll be pushing these to Linus and -stable shortly.

Thanks.
