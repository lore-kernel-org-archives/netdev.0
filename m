From: David Miller <davem@davemloft.net>
Subject: Re: cannot set IP for ethernet
Date: Wed, 13 Jun 2007 20:56:34 -0700 (PDT)
Message-ID: <20070613.205634.45179442.davem@davemloft.net>
References: <200706121441.13561.oliver@neukum.org>
	<466EA861.2070509@trash.net>
	<20070614035341.GA21010@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, oliver@neukum.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59979
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752544AbXFND4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 23:56:17 -0400
In-Reply-To: <20070614035341.GA21010@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 14 Jun 2007 13:53:41 +1000

> Actually in his case it's because 2.6.22-rc4-git2 doesn't have the
> following changeset.

It's on the way, it just hasn't been picked up yet.
