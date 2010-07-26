From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Mon, 26 Jul 2010 13:48:26 -0700 (PDT)
Message-ID: <20100726.134826.232739122.davem@davemloft.net>
References: <20100725.215548.112589000.davem@davemloft.net>
	<20100726.130821.179918086.davem@davemloft.net>
	<1280176743.2531.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39056
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751608Ab0GZUsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 16:48:09 -0400
In-Reply-To: <1280176743.2531.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 26 Jul 2010 22:39:03 +0200

> Cannot remember if I compiled v3 of the patch, to be honest.

It's impossible that you did so, there is a missing
closing parenthesis in the first if() statement added
by your patch :-)
