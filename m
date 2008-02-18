From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/8021q/vlan_dev.c - Use print_mac
Date: Sun, 17 Feb 2008 23:35:04 -0800 (PST)
Message-ID: <20080217.233504.226699494.davem@davemloft.net>
References: <20080215104804.9870.15722.stgit@one>
	<20080215.025855.202184003.davem@davemloft.net>
	<1203097370.21308.18.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, bruno@thinktube.com, netdev@vger.kernel.org,
	jgarzik@pobox.com, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35252
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753900AbYBRHe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 02:34:27 -0500
In-Reply-To: <1203097370.21308.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 15 Feb 2008 09:42:50 -0800

> On Fri, 2008-02-15 at 02:58 -0800, David Miller wrote:
> > From: Bruno Randolf <bruno@thinktube.com>
> > Date: Fri, 15 Feb 2008 19:48:05 +0900
> > > is there any chance to include a macro like this for printing mac
> > addresses?
> > > its advantage is that it can be used without the need to declare
> > buffers for
> > > print_mac(), for example:
> > We specifically removed this sort of thing, please don't
> > add it back.
> 
> Remove direct use of MAC_FMT
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
