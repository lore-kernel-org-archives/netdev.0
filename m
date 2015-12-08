From: David Miller <davem@davemloft.net>
Subject: Re: Checksum offload queries
Date: Tue, 08 Dec 2015 12:28:30 -0500 (EST)
Message-ID: <20151208.122830.2146242421346445433.davem@davemloft.net>
References: <5666FF46.6030702@solarflare.com>
	<20151208.120911.1930136653560954435.davem@davemloft.net>
	<56671267.9090607@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbbLHR2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 12:28:32 -0500
In-Reply-To: <56671267.9090607@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 8 Dec 2015 17:24:55 +0000

> The context here was transmit, not receive; the stack muxes
> encapsulation layers and then asks the hardware to fill in one
> checksum, it doesn't have any way to fill in 'adjusted' checksums in
> other layers.  The following paragraph (which you snipped) was
> discussing ways to get this kind of adjusted checksumming on
> transmit, by feeding the adjustments to the hardware.

[ Please properly line-wrap your emails, it looks like one very long
  line to everyone on the list. ]

See Tom's reply re: TX.
