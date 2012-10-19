From: Willy Tarreau <w@1wt.eu>
Subject: Re: [stable 2.6.32.y PATCH 0/6] net: fixes for cached dsts are never invalidated
Date: Fri, 19 Oct 2012 21:55:57 +0200
Message-ID: <20121019195557.GG17417@1wt.eu>
References: <20121019191347.GD13515@kvack.org> <20121019194822.GF17417@1wt.eu> <20121019.154930.215119663249874810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bcrl@kvack.org, stable@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:33806 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758304Ab2JST4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 15:56:03 -0400
Content-Disposition: inline
In-Reply-To: <20121019.154930.215119663249874810.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 03:49:30PM -0400, David Miller wrote:
> 
> How about checking if these changes are already in 3.0/3.2/etc. or not
> before asking such questions?

Because I didn't find the patches in 3.0 and Ben said he backported them
from 3.6, I think these are two valid reasons to ask, no ?

Willy
