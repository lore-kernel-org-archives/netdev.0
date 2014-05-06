From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/24] net, diet: Make raw sockets optional
Date: Mon, 05 May 2014 23:12:51 -0400 (EDT)
Message-ID: <20140505.231251.214794413461688735.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-19-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933809AbaEFDMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 23:12:53 -0400
In-Reply-To: <1399328773-6531-19-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:26:07 -0700

> Not really needed on small embedded systems.  Saves about 5k text,
> more with IPv6.

Sorry, you can't have half a functioning ipv4 stack.

I'm not applying this.
