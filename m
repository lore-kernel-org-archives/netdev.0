From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Cleanup of neighbour code
Date: Wed, 12 Nov 2008 00:55:30 -0800 (PST)
Message-ID: <20081112.005530.78411533.davem@davemloft.net>
References: <20081111.164554.143409564.davem@davemloft.net>
	<491A75BE.1010907@cosmosbay.com>
	<491A785E.5060903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43910
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751484AbYKLIzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 03:55:31 -0500
In-Reply-To: <491A785E.5060903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 12 Nov 2008 07:31:58 +0100

> Using read_pnet() and write_pnet() in neighbour code ease the reading of code.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Happily applied.

Now that's what I'm talking about!  Put that ifdef shit in the
header files!

Whoot!

