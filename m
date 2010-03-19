From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] KS8851: Avoid NULL pointer in set rx mode
Date: Thu, 18 Mar 2010 21:08:05 -0700 (PDT)
Message-ID: <20100318.210805.245382521.davem@davemloft.net>
References: <cb8016981003161524w6601d5e7i3885f77219582a0a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpirko@redhat.om
To: abraham.arce.moreno@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36081
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750695Ab0CSEHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 00:07:43 -0400
In-Reply-To: <cb8016981003161524w6601d5e7i3885f77219582a0a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Abraham Arce <abraham.arce.moreno@gmail.com>
Date: Tue, 16 Mar 2010 16:24:54 -0600

> Kernel NULL pointer dereference when setting mode for IFF_MULTICAST.
> Tested on SDP OMAP4430 board.

I'll apply this, thanks.

Jiri, just FYI, this bug was added by your mclist conversion.
