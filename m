From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/13] net: mvneta: implement rx_copybreak
Date: Thu, 16 Jan 2014 12:11:42 -0800 (PST)
Message-ID: <20140116.121142.2227761738746127874.davem@davemloft.net>
References: <20140116093640.GA16457@1wt.eu>
	<20140116.114905.1582218754259744747.davem@davemloft.net>
	<20140116200757.GA19969@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbaAPULn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 15:11:43 -0500
In-Reply-To: <20140116200757.GA19969@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Thu, 16 Jan 2014 21:07:57 +0100

> So such a change would probably require to add a number
> of new calls to the DMA API. I really don't know what's the best solution
> would be in fact :-/

Right, thanks for explaining your situation.
