From: David Miller <davem@davemloft.net>
Subject: Re: net 00/05: routing based send-to-self implementation
Date: Thu, 03 Dec 2009 12:15:14 -0800 (PST)
Message-ID: <20091203.121514.20643462.davem@davemloft.net>
References: <20091203112550.15100.86217.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34578
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753482AbZLCUPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:15:08 -0500
In-Reply-To: <20091203112550.15100.86217.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu,  3 Dec 2009 12:25:52 +0100 (MET)

> These patches are yet another attempt at adding "send-to-self" functionality,
> allowing to send packets between two local interfaces over the wire. Unlike
> the approaches I've seen so far, this one is purely routing based.
> Especially the oif classification should also be useful for different setups.
...
> Please apply, thanks!

All applied to net-next-2.6, thanks!
