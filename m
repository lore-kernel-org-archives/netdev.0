From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 5/5][LIB]: Drop the pcounter itself.
Date: Fri, 28 Mar 2008 16:40:53 -0700 (PDT)
Message-ID: <20080328.164053.242165841.davem@davemloft.net>
References: <47ECE719.5090409@openvz.org>
	<47ED2903.3060807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51123
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756413AbYC1Xk5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 19:40:57 -0400
In-Reply-To: <47ED2903.3060807@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 28 Mar 2008 18:21:07 +0100

> Pavel Emelyanov a =E9crit :
> > The knock-out. The pcounter abstraction is not used any longer
> > in the kernel.
> >
> > Not sure whether this should go via netdev tree, but as far as
> > I remember it was added via this one, and besides Eric thinks
> > that Andrew shouldn't mind this.
> >
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> >
> >  =20
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.

Yes it should go via the net tree, we added the crap
we should remove it :-)
