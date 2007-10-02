From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 02 Oct 2007 14:50:34 -0700 (PDT)
Message-ID: <20071002.145034.15615464.davem@davemloft.net>
References: <20071002142016.GE7881@ghostprotocols.net>
	<4702B1FD.70102@hartkopp.net>
	<20071002214325.GB3576@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@hartkopp.net, urs@isnogud.escape.de, netdev@vger.kernel.org,
	kaber@trash.net, tglx@linutronix.de, yoshfuji@linux-ipv6.org,
	ebiederm@xmission.com, oliver.hartkopp@volkswagen.de,
	urs.thuermann@volkswagen.de
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47477
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753901AbXJBVuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:50:35 -0400
In-Reply-To: <20071002214325.GB3576@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 2 Oct 2007 18:43:25 -0300

> I think that helping ctags to find the definition for the debug variable
> to see, for instance, if it is a bitmask or a boolean without having to
> chose from tons of 'debug' variables is a good thing.

I completely agree.
