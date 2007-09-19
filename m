From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Wed, 19 Sep 2007 12:54:51 -0700 (PDT)
Message-ID: <20070919.125451.112289690.davem@davemloft.net>
References: <1190177401.19708.264.camel@localhost>
	<20070919.111147.55510143.davem@davemloft.net>
	<1190227854.26101.9.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, jgarzik@pobox.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40692
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750962AbXISTyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 15:54:52 -0400
In-Reply-To: <1190227854.26101.9.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 19 Sep 2007 11:50:54 -0700

> On Wed, 2007-09-19 at 11:11 -0700, David Miller wrote:
> > Can you just extract out one single patch that does the MAC_FMT change
> > and get that to me somehow?
> 
> Signed-off-by:  Joe Perches <joe@perches.com>
> 
> pull from:
> 
> git://repo.or.cz/linux-2.6/trivial-mods.git print_mac
> 
> or use the attached bz2

The newly added wireless drivers needed some MAC_FMT conversions,
which I took care of.

Applied to net-2.6.24, thanks Joe!
