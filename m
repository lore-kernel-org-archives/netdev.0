From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: make functions static
Date: Thu, 21 Oct 2010 03:13:42 -0700 (PDT)
Message-ID: <20101021.031342.59686120.davem@davemloft.net>
References: <20101018082731.36cd65e4@nehalam>
	<1287421518.2252.219.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, shodgson@solarflare.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60513
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754525Ab0JUKNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:13:20 -0400
In-Reply-To: <1287421518.2252.219.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 18 Oct 2010 18:05:18 +0100

> On Mon, 2010-10-18 at 08:27 -0700, Stephen Hemminger wrote:
>> Make local functions and variable static. Do some rearrangement
>> of the string table stuff to put it where it gets used.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> We might have to change some of these back in future, but I suppose
> there is no harm in making them static now.

Applied.
