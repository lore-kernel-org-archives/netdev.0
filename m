From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCHv3] printk: add %pM format specifier for MAC
 addresses
Date: Mon, 27 Oct 2008 15:46:00 -0700 (PDT)
Message-ID: <20081027.154600.251121145.davem@davemloft.net>
References: <20081027.123805.134354592.davem@davemloft.net>
	<1225137542.5396.10.camel@brick>
	<1225144515.5269.40.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, johannes@sipsolutions.net,
	anders@anduras.de, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33218
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751215AbYJ0WqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 18:46:23 -0400
In-Reply-To: <1225144515.5269.40.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 27 Oct 2008 14:55:15 -0700

> On Mon, 2008-10-27 at 12:59 -0700, Harvey Harrison wrote:
> 
> > +static char *mac_address(char *buf, char *end, u8 *addr, int field_width,
> > +			 int precision, int flags)
> > +{
> 
> mac_address_string please.

I'll make this change when I apply Harvey's patch.
