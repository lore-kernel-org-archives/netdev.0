From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] Gigaset driver patches for 2.6.33
Date: Thu, 29 Oct 2009 01:37:38 -0700 (PDT)
Message-ID: <20091029.013738.257529406.davem@davemloft.net>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, hjlipp@web.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751484AbZJ2IhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 04:37:14 -0400
In-Reply-To: <20091023-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sun, 25 Oct 2009 20:29:27 +0100 (CET)

> David, Karsten,
> 
> here's a series of patches that should be applied on top of those
> currently in net-next. I'm sending them now to leave you enough time
> before the next merge window to decide who wants to handle them.
> In particular, patch 3 provides an important bugfix to the new CAPI
> interface which is necessary for using it with pppd capiplugin.

All of these patches look reasonable, so I've applied them
to net-next-2.6

Thanks!
