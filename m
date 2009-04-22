From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2] Documentation/isdn/INTERFACE.CAPI
Date: Wed, 22 Apr 2009 02:31:42 -0700 (PDT)
Message-ID: <20090422.023142.222186658.davem@davemloft.net>
References: <49E4E9CA.8000802@imap.cc>
	<20090421091852.9C31C111815@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn4linux@listserv.isdn4linux.de, isdn@linux-pingi.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41689
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751607AbZDVJbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 05:31:49 -0400
In-Reply-To: <20090421091852.9C31C111815@xenon.ts.pxnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Tue, 21 Apr 2009 11:18:52 +0200 (CEST)

> @@ -8,6 +8,8 @@ INTERFACE
>  	- description of isdn4linux Link Level and Hardware Level interfaces.
>  INTERFACE.fax
>  	- description of the fax subinterface of isdn4linux.
> +INTERFACE.CAPI
> +	- description of kernel CAPI Link Level to Hardware Level interface.
>  README
>  	- general info on what you need and what to do for Linux ISDN.
>  README.FAQ

There is no INTERFACE.fax entry in this file in the current
tree.

I wanted to apply this, but aparently your patch is against
something other than Linus's tree or net-2.6

