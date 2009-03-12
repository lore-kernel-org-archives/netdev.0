From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 06:03:21 -0700 (PDT)
Message-ID: <20090312.060321.93794599.davem@davemloft.net>
References: <1295ed070903120547q431b5b40n71b8d2e98719e18d@mail.gmail.com>
	<20090312.055235.56926675.davem@davemloft.net>
	<1295ed070903120558u33d633f4v1622ef56a06066a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, rusty@rustcorp.com.au, netdev@vger.kernel.org
To: pktoss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752308AbZCLNDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 09:03:34 -0400
In-Reply-To: <1295ed070903120558u33d633f4v1622ef56a06066a0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pantelis Koukousoulas <pktoss@gmail.com>
Date: Thu, 12 Mar 2009 14:58:28 +0200

> > If the link is always on, you should make that explicit by providing
> > a link state handler, and making sure it always returns true.
> 
> So, you agree that my patch that does exactly that is correct ?

Yes, absolutely.
