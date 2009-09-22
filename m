From: David Miller <davem@davemloft.net>
Subject: Re: [GIT *] Solos PCI ADSL driver update
Date: Tue, 22 Sep 2009 15:19:13 -0700 (PDT)
Message-ID: <20090922.151913.45863779.davem@davemloft.net>
References: <1253481424.6317.203.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45127
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753338AbZIVWSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 18:18:55 -0400
In-Reply-To: <1253481424.6317.203.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 20 Sep 2009 14:17:04 -0700

> I'm sorry, I suck. I forgot I had anything outstanding to be pushed
> upstream, and should have done this a while ago.
> 
> In later versions of the card's FPGA code, the RAM layout for
> card<->host communication has changed -- and the new FPGA code is in the
> devices which are being shipped now, so it would be really useful if we
> could sneak this into 2.6.32. Sorry it's so late.
> 
> Please pull from git://git.infradead.org/users/dwmw2/solos-2.6.git

Pulled, thanks.
