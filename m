From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sb1250: setup the pdevice within the soc code
Date: Tue, 27 Apr 2010 15:55:00 -0700 (PDT)
Message-ID: <20100427.155500.135970411.davem@davemloft.net>
References: <20100426204122.GA23697@Chamillionaire.breakpoint.cc>
	<20100426210022.GE27656@linux-mips.org>
	<20100426210744.GA23721@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org
To: sebastian@breakpoint.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43142
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755088Ab0D0Wyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:54:54 -0400
In-Reply-To: <20100426210744.GA23721@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Mon, 26 Apr 2010 23:07:44 +0200

> doing it within the driver does not look good.
> And surely isn't how platform devices were meat to be used.
> 
> Acked-by: Ralf Baechle <ralf@linux-mips.org>
> Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>

Applied to net-next-2.6, thanks.
