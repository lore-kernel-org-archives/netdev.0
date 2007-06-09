From: David Miller <davem@davemloft.net>
Subject: Re: networking busted in current -git ???
Date: Fri, 08 Jun 2007 19:06:08 -0700 (PDT)
Message-ID: <20070608.190608.117446027.davem@davemloft.net>
References: <20070608205640.GI30661@iucha.net>
	<200706082307.45722.arekm@maven.pl>
	<1181339007.6675.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arekm@maven.pl, florin@iucha.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S967864AbXFICFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 22:05:53 -0400
In-Reply-To: <1181339007.6675.12.camel@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: Fri, 08 Jun 2007 17:43:27 -0400

> It is not dhcp. I'm seeing the same bug with bog-standard ifup with a
> static address on an FC-6 machine.
> 
> It appears to be something in the latest dump from davem to Linus, but I
> haven't yet had time to identify what.

Linus's current tree should have this fixed.

Let us know if this is not the case.
