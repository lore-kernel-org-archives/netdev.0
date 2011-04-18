From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] via-rhine: Assign random MAC address if necessary
Date: Sun, 17 Apr 2011 17:57:01 -0700 (PDT)
Message-ID: <20110417.175701.209965647.davem@davemloft.net>
References: <4DAA12C0.7030106@gmail.com>
	<cover.1302998994.git.joe@perches.com>
	<c7efaaf6a943f911162261edd7a2186086cda953.1302998994.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mr.nuke.me@gmail.com, rl@hellgate.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33766
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753729Ab1DRA5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:57:36 -0400
In-Reply-To: <c7efaaf6a943f911162261edd7a2186086cda953.1302998994.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 16 Apr 2011 17:15:26 -0700

> Roger Luethi has had several reports of Rhine NICs providing
> an invalid MAC address.  If so, assign a random MAC address so
> the hardware can still be used.
> 
> Tested as a standalone interface, as carrier for ppp, and as a
> bonding slave.
> 
> Original-patch-by: Alexandru Gagniuc <mr.nuke.me@gmail.com>
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
