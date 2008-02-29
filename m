From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 3/4] Use seq_open_private in appletalk and
 decnet.
Date: Fri, 29 Feb 2008 11:38:32 -0800 (PST)
Message-ID: <20080229.113832.128771062.davem@davemloft.net>
References: <47C80D28.9020009@openvz.org>
	<20080229141059.GK4306@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org,
	christine.caulfield@googlemail.com
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48220
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753813AbYB2Tid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:38:33 -0500
In-Reply-To: <20080229141059.GK4306@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 29 Feb 2008 11:10:59 -0300

> Em Fri, Feb 29, 2008 at 04:48:24PM +0300, Pavel Emelyanov escreveu:
> > These two also perform manual seq_open_private, so patch them both
> > at once. But unlike ATM code, these already use the seq_release_private, 
> > so I splitted this patch from the previous one.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied, thanks.
