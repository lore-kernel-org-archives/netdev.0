From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: A little dev_valid_name() improvement
Date: Sun, 18 Jan 2009 18:17:51 -0800 (PST)
Message-ID: <20090118.181751.187711018.davem@davemloft.net>
References: <8496f91a0901181107o17ee80e7h7fab67194a7bde23@mail.gmail.com>
	<497390FE.4050909@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matvejchikov@gmail.com, netdev@vger.kernel.org
To: mjt@tls.msk.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48335
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758043AbZASCRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 21:17:50 -0500
In-Reply-To: <497390FE.4050909@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Tokarev <mjt@tls.msk.ru>
Date: Sun, 18 Jan 2009 23:28:46 +0300

> Matvejchikov Ilya wrote:
> > This patch removes redundant complexity when checking the
> > network device name to be valid.
> 
> And also disallows any name starting with a dot, while
> previously it was allowed/valid.
> 
> I don't think this patch is good.

Agreed, I'm not applying this.
