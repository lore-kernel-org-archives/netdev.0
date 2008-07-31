From: David Miller <davem@davemloft.net>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 18:23:09 -0700 (PDT)
Message-ID: <20080730.182309.35986438.davem@davemloft.net>
References: <1217459102.18911.182.camel@calx>
	<20080730.162153.124485443.davem@davemloft.net>
	<1217466609.18911.227.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44534
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753601AbYGaBXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 21:23:09 -0400
In-Reply-To: <1217466609.18911.227.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Mackall <mpm@selenic.com>
Date: Wed, 30 Jul 2008 20:10:09 -0500

> Of course not. It's a webcam. Or it's a printer or game console or media
> streamer or alarm clock or BluRay player, etc. Yes, I do have a
> Linux-powered alarm clock (A Nokia N800) and no, it doesn't have a
> firewall.

Most game consoles and cell phones make use of either firewalling
or IPSEC, or both.

Looking at various kernel boot message logs of N800's posted online,
it seems to have netfilter enabled.  The ip_tables module does get
loaded.
