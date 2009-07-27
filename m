From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fealnx: Write outside array bounds
Date: Sun, 26 Jul 2009 19:01:28 -0700 (PDT)
Message-ID: <20090726.190128.226468902.davem@davemloft.net>
References: <4A699FC2.2080407@gmail.com>
	<Pine.LNX.4.64.0907251253350.26274@melkinkari.cs.Helsinki.FI>
	<4A6B43B8.3070209@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44669
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755679AbZG0CBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 22:01:22 -0400
In-Reply-To: <4A6B43B8.3070209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sat, 25 Jul 2009 19:41:12 +0200

> phy_idx is checked to be < 4, but np->phys[] is 2 elements long
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
