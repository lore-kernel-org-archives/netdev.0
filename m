From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sat, 23 Jun 2007 13:51:13 -0700 (PDT)
Message-ID: <20070623.135113.67582141.davem@davemloft.net>
References: <ygfk5tw41rq.fsf@janus.isnogud.escape.de>
	<467BC2AF.8080901@trash.net>
	<467D0C97.1000000@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, j.hadi123@gmail.com, urs@isnogud.escape.de,
	tglx@linutronix.de, oliver.hartkopp@volkswagen.de,
	netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48555
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751385AbXFWUuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 16:50:55 -0400
In-Reply-To: <467D0C97.1000000@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Sat, 23 Jun 2007 14:05:43 +0200

> i was just looking through the mailings regarding your suggested changes
> (e.g. in VLAN, DUMMY and IFB) an none of them currently went into the
> kernel and the discussion on some topics (especially in the VLAN case)
> is just running.

This code is in the net-2.6 GIT tree of mine at:

	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

which is what you should be doing all of your networking
development against, and generating patches against, anyways.

Anything in that tree is scheduled for 2.6.23 inclusion, therefore
if a preferred interface has been added there, you better use it
for any new code.
