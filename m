From: David Miller <davem@davemloft.net>
Subject: Re: fix-slab-corruption-running-ip6sic.patch
Date: Thu, 26 Apr 2007 14:59:32 -0700 (PDT)
Message-ID: <20070426.145932.13769222.davem@davemloft.net>
References: <20070426141133.21ef2e17.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jarkao2@o2.pl, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45644
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755085AbXDZV70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 17:59:26 -0400
In-Reply-To: <20070426141133.21ef2e17.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 26 Apr 2007 14:11:33 -0700

> 
> I have this floating about in my tree.  Is it of any interest?

I have it too, it's in my backlog which I'm not processing
because I'm trying to fix up how we screwed up both networking
"security" fixes by adding a new regression with each one :-)
