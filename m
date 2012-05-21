From: David Miller <davem@davemloft.net>
Subject: Re: Network driver git tree
Date: Mon, 21 May 2012 00:40:18 -0400 (EDT)
Message-ID: <20120521.004018.1895457760093738466.davem@davemloft.net>
References: <CAGXs5wX3VAWNsV49Eg_Nznhbsuo4t=4b5h6_KrgPzPZ0=Qp4og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wkevils@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946Ab2EUEkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 00:40:20 -0400
In-Reply-To: <CAGXs5wX3VAWNsV49Eg_Nznhbsuo4t=4b5h6_KrgPzPZ0=Qp4og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Wilson <wkevils@gmail.com>
Date: Mon, 21 May 2012 07:34:52 +0300

> In the past there was a git tree of Jeff Garzik for the network
> drivers; once in a while the net-next git tree pulled code from this
> tree. My short question is: currently, is a new, fresh network
> driver sent directly to net-next ? or is there some git tree similar
> to Jeff Garzik git tree (or maybe it does still exist)?

Jeff's tree hasn't existed in years.

All networking changes are sent to the net-next tree directly.
