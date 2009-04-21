From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2] Documentation/isdn/INTERFACE.CAPI
Date: Tue, 21 Apr 2009 02:21:39 -0700 (PDT)
Message-ID: <20090421.022139.163997118.davem@davemloft.net>
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
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43096
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753966AbZDUJVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 05:21:47 -0400
In-Reply-To: <20090421091852.9C31C111815@xenon.ts.pxnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Tue, 21 Apr 2009 11:18:52 +0200 (CEST)

> isdn: document Kernel CAPI driver interface
> 
> Create a file Documentation/isdn/INTERFACE.CAPI describing the
> interface between the kernel CAPI subsystem and ISDN device drivers,
> analogous to the existing Documentation/isdn/INTERFACE for the old
> isdn4linux subsystem. Also add kerneldoc comments to the exported
> functions in drivers/isdn/capi/kcapi.c.
> 
> Impact: Documentation
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

If someone can give this a general review, I'll queue it up
in net-2.6

Thanks!
