From: David Miller <davem@davemloft.net>
Subject: Re: "src" attribute ignored for IPv6 (preferred source address
 selection)
Date: Fri, 29 Oct 2010 13:11:06 -0700 (PDT)
Message-ID: <20101029.131106.183062581.davem@davemloft.net>
References: <4C8215C8.8000908@httrack.com>
	<20101017011205.GA10610@srv03.cluenet.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dr@cluenet.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51008
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757422Ab0J2UKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 16:10:42 -0400
In-Reply-To: <20101017011205.GA10610@srv03.cluenet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Roesen <dr@cluenet.de>
Date: Sun, 17 Oct 2010 03:12:08 +0200

> http://lkml.indiana.edu/hypermail/linux/kernel/0409.0/1768.html
> 
> Unfortunately I don't have the time (and most probably not the necessary
> kernel knowhow) to hack this up myself, but I'm still interested. :-)

The routing table in ipv6 can very much handle routing by source
address now, if the ip commands mention do not work it's some
bug in the tool or the routing table rule adding code in the
kernel.

It's not a fundamental limitation any more.
