From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] rtnetlink.c: remove no longer used functions
Date: Tue, 05 Feb 2008 03:17:33 -0800 (PST)
Message-ID: <20080205.031733.37065544.davem@davemloft.net>
References: <20080130200257.GD29368@does.not.exist>
	<47A0D851.9050408@trash.net>
	<20080201161904.GA12176@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33656
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750933AbYBELRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:17:06 -0500
In-Reply-To: <20080201161904.GA12176@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Fri, 1 Feb 2008 18:19:04 +0200

> On Wed, Jan 30, 2008 at 09:04:33PM +0100, Patrick McHardy wrote:
> > Adrian Bunk wrote:
> >> This patch #if 0's the following no longer used functions:
> >> - rtattr_parse()
> >> - rtattr_strlcpy()
> >> - __rtattr_parse_nested_compat()
> >>   
> >
> > Please remove them instead.
> 
> Updated patch below.

Applied, thanks Adrian.
