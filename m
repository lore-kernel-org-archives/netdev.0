From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 18:05:27 -0700 (PDT)
Message-ID: <20120619.180527.65196005824751590.davem@davemloft.net>
References: <1340151666.6871.81.camel@deadeye.wl.decadent.org.uk>
	<20120619.175435.1705108432673390966.davem@davemloft.net>
	<1340154206.6871.90.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454Ab2FTBF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 21:05:28 -0400
In-Reply-To: <1340154206.6871.90.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 20 Jun 2012 02:03:26 +0100

> On Tue, 2012-06-19 at 17:54 -0700, David Miller wrote:
>> The hash is perfect, what's the big deal?
> 
> It obscures what we're really doing and relying on.

If it matters to you, patches are always welcome :-)
