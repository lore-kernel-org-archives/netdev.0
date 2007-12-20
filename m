From: David Miller <davem@davemloft.net>
Subject: Re: A short question about net git tree and patches
Date: Thu, 20 Dec 2007 03:22:58 -0800 (PST)
Message-ID: <20071220.032258.265124532.davem@davemloft.net>
References: <31436f4a0712200120o4e6de008jf999ca1024b47f9d@mail.gmail.com>
	<20071220095510.GA2081@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dshwatrz@gmail.com, netdev@vger.kernel.org
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759398AbXLTLW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 06:22:59 -0500
In-Reply-To: <20071220095510.GA2081@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 20 Dec 2007 10:55:10 +0100

> net-2.6.25.git   <= patches for current kernel release (only fixes)
> net-2.6.git      <= patches for next kernel relase and planned to be
>                     applied in next merge window
> 
> So net-2.6.git is the correct choice for bleeding edge.

You reversed them, net-2.6.25.git is for bleeding edge
stuff, net-2.6.git is for bug fixes only.
