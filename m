From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: [2.6.26] OOPS in __linkwatch_run_queue (unable to
 handle kernel NULL pointer dereference at 00000235)
Date: Mon, 17 Nov 2008 01:15:09 -0800 (PST)
Message-ID: <20081117.011509.71878779.davem@davemloft.net>
References: <20081117084058.GA6345@ff.dom.local>
	<20081117.005025.141630310.davem@davemloft.net>
	<20081117091108.GB6345@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: folkert@vanheusden.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56356
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752554AbYKQJPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 04:15:09 -0500
In-Reply-To: <20081117091108.GB6345@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 17 Nov 2008 09:11:08 +0000

> On Mon, Nov 17, 2008 at 12:50:25AM -0800, David Miller wrote:
> Yes, this looks very nice! But this should be done in "a few" more
> drivers, like cxgb3 etc.

Thanks for pointing that out, I'll fix those cases too.

> PS: I think "Reported-by" could stay anyway.

Absolutely, I'll fix that.
