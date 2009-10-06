From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: arp_notify address list bug
Date: Mon, 05 Oct 2009 21:31:03 -0700 (PDT)
Message-ID: <20091005.213103.237708475.davem@davemloft.net>
References: <20091005191505.75c929a6@nehalam>
	<4ACAB5BC.1020307@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53236
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750831AbZJFEbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 00:31:08 -0400
In-Reply-To: <4ACAB5BC.1020307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Oct 2009 05:13:00 +0200

> I suggest splitting patch in two parts, one to fix the bug for linux-2.6 and stable,
> and another one for net-next-2.6 for the enhancement ?
> 

Good idea.
