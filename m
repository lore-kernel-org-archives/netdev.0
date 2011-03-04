From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inetpeer: seqlock optimization
Date: Fri, 04 Mar 2011 11:17:05 -0800 (PST)
Message-ID: <20110304.111705.193726268.davem@davemloft.net>
References: <1299137977.2456.15.camel@edumazet-laptop>
	<20110303.003229.229764095.davem@davemloft.net>
	<1299251348.2676.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37696
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760067Ab1CDTQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 14:16:29 -0500
In-Reply-To: <1299251348.2676.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 04 Mar 2011 16:09:08 +0100

> Here is a patch to implement this idea.

Applied, thanks Eric!
