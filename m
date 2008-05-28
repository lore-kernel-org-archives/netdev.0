From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 19:42:32 +0400
Message-ID: <20080528154232.GA17339@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com> <200805281620.55578.opurdila@ixiacom.com> <20080528141104.GA5543@2ka.mipt.ru> <200805281820.02143.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58829 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084AbYE1Pml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 11:42:41 -0400
Content-Disposition: inline
In-Reply-To: <200805281820.02143.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2008 at 06:20:02PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> OK, will clean it up and post a proper patch soon. Which tree should I base it 
> on?

Vanilla tree I think, it should apply without problems to all trees,
since patch is rather small.

-- 
	Evgeniy Polyakov
