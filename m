From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Linux IPV6_SUBTREES not functioning
Date: Tue, 6 Aug 2013 10:30:05 +0200
Message-ID: <20130806083005.GC2941@order.stressinduktion.org>
References: <8CBF8819-E1D9-445E-9E7C-793422934733@inf-net.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, boutier@pps.univ-paris-diderot.fr
To: Teco Boot <teco@inf-net.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:33929 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472Ab3HFIaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 04:30:08 -0400
Content-Disposition: inline
In-Reply-To: <8CBF8819-E1D9-445E-9E7C-793422934733@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, Aug 02, 2013 at 12:15:03PM +0200, Teco Boot wrote:
> For destination & source address routing, I prefer the single routing table approach with IPV6_SUBTREES over the multiple tables with ip rules approach.
> Can some take a look at my findings? It looks broken. It seems the source address check in route cache is missing.

Have you verified this behaviour with actual network traffic?

Greetings,

  Hannes
