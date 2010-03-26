From: David Miller <davem@davemloft.net>
Subject: Re: [Regression] r8169: enable 64-bit DMA by default for PCI
 Express devices (v2)
Date: Thu, 25 Mar 2010 20:29:10 -0700 (PDT)
Message-ID: <20100325.202910.232567167.davem@davemloft.net>
References: <20100316083501.GA3489@Dublin.logfs.org>
	<51f3faa71003161630g69160ea9tc1a2d448682632e5@mail.gmail.com>
	<51f3faa71003251756h17374375yd3a5d2acee2ffab9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joern@dublin.logfs.org, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: hancockrwd@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45302
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754139Ab0CZD2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 23:28:47 -0400
In-Reply-To: <51f3faa71003251756h17374375yd3a5d2acee2ffab9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Hancock <hancockrwd@gmail.com>
Date: Thu, 25 Mar 2010 18:56:03 -0600

> Francois, ping? Is there anyone else that has access to this kind of
> information about these chips?

Francois didn't have time to resolve a remotely exploitable
DoS bug in this driver, I doubt he has time to resolve something
like this.

It isn't going to be resolved any time soon, so I'm reverting
the guilty change now.

Thanks.
