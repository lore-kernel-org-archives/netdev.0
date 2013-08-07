From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Wed, 7 Aug 2013 22:06:37 +0200
Message-ID: <20130807200637.GD32257@order.stressinduktion.org>
References: <20130807003431.GD16410@order.stressinduktion.org> <EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	equinox@diac24.net, boutier@pps.univ-paris-diderot.fr
To: Teco Boot <teco@inf-net.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37769 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932713Ab3HGUGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 16:06:38 -0400
Content-Disposition: inline
In-Reply-To: <EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 07, 2013 at 09:58:31PM +0200, Teco Boot wrote:
> Seems to work!!
> 
> babe has one entry less than cafe, this is correct.
> Tomorrow I'll test with real traffic.

Thanks for testing! I already used real traffic but it is better to
double check.

Greetings,

  Hannes
