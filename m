From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] r6040: Fix multicast filter some more
Date: Tue, 19 Oct 2010 04:06:34 -0700 (PDT)
Message-ID: <20101019.040634.260094325.davem@davemloft.net>
References: <1287112636.20865.13.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52424
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758178Ab0JSLGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 07:06:11 -0400
In-Reply-To: <1287112636.20865.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 15 Oct 2010 04:17:16 +0100

> This code has been broken forever, but in several different and
> creative ways.
 ...
> That commit fixes the most important current bug #6.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Thanks for doing all of this tedious analysis and work.

Applied.
