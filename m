From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable 2/2] l2tp: Fix sendmsg() return value
Date: Thu, 13 Jun 2013 02:39:33 -0700 (PDT)
Message-ID: <20130613.023933.1785541703499775074.davem@davemloft.net>
References: <cover.1371044671.git.g.nault@alphalink.fr>
	<20130612140736.GC3500@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756822Ab3FMJje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:39:34 -0400
In-Reply-To: <20130612140736.GC3500@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 12 Jun 2013 16:07:36 +0200

> PPPoL2TP sockets should comply with the standard send*() return values
> (i.e. return number of bytes sent instead of 0 upon success).
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied.
