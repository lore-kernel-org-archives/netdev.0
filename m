From: David Miller <davem@davemloft.net>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Wed, 12 May 2010 15:24:06 -0700 (PDT)
Message-ID: <20100512.152406.193725816.davem@davemloft.net>
References: <1273611036.2512.18.camel@edumazet-laptop>
	<1273634421.2512.21.camel@edumazet-laptop>
	<20100512152207.0e0c321a@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, Bijay.Singh@guavus.com, bhaskie@gmail.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36377
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757120Ab0ELWYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 18:24:00 -0400
In-Reply-To: <20100512152207.0e0c321a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 12 May 2010 15:22:07 -0700

> Yes, that looks like a possible bug, not sure what hardware
> generates frag_list.

GRO generates frag_list
