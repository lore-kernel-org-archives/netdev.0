From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 1/2] Shrink size of net_device by filling
 alignment holes in it.
Date: Wed, 16 Apr 2008 02:12:35 -0700 (PDT)
Message-ID: <20080416.021235.111507104.davem@davemloft.net>
References: <47FA5717.4070901@cosmosbay.com>
	<20080407174745.GE15681@ghostprotocols.net>
	<47FB2FAE.3080008@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, dada1@cosmosbay.com, netdev@vger.kernel.org,
	shemminger@vyatta.com, kaber@trash.net
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751354AbYDPJMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 05:12:34 -0400
In-Reply-To: <47FB2FAE.3080008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Apr 2008 12:41:18 +0400

> Ok, here are the results (summary):
 ...
> So, does it worth trying to push them to Dave? :)

I think if you can at least make it such that it stays
the same in all of the stated situations, I'm happy to
apply this.

Get creative with the rearrangement :-)
