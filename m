From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCHv2] printk: add the %pM, %p4, %p6 format specifiers
Date: Mon, 27 Oct 2008 12:38:05 -0700 (PDT)
Message-ID: <20081027.123805.134354592.davem@davemloft.net>
References: <1225067465.5672.1.camel@brick>
	<1225090765.3746.7.camel@johannes.berg>
	<1225124904.5440.1.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, anders@anduras.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53366
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750784AbYJ0Ti2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 15:38:28 -0400
In-Reply-To: <1225124904.5440.1.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Mon, 27 Oct 2008 09:28:24 -0700

> On Mon, 2008-10-27 at 07:59 +0100, Johannes Berg wrote:
> 
> > Also can you keep mac/ip address patches split up so we can use my
> > version of the mac address patch (it's already well-tested)?
> > 
> 
> Sure.  I'll build on top.

So I'll wait for Harvey's "v3" of this patch, and once I have that in
the net-next-2.6 tree I'll start adding Johannes's conversions on top.
