From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 3/5][SOCK]: Drop per-proto inuse init and
 fre functions (v2).
Date: Fri, 28 Mar 2008 16:40:31 -0700 (PDT)
Message-ID: <20080328.164031.24593203.davem@davemloft.net>
References: <47ECE605.1050403@openvz.org>
	<47ED2877.7010209@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754432AbYC1Xkf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 19:40:35 -0400
In-Reply-To: <47ED2877.7010209@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 28 Mar 2008 18:18:47 +0100

> Pavel Emelyanov a =E9crit :
> > Constructive part of the set is finished here. We have to
> > remove the pcounter, so start with its init and free
> > functions.
> >
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> >
> >  =20
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.
