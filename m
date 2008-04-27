From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix typo in net/ipv6/Kconfig
Date: Sat, 26 Apr 2008 22:51:12 -0700 (PDT)
Message-ID: <20080426.225112.112596327.davem@davemloft.net>
References: <20080424084009.61f773a6@snafu.setup>
	<20080424.235043.152016786.davem@davemloft.net>
	<Pine.LNX.4.55.0804260059050.13902@cliff.in.clinika.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: youvegotmoxie@gmail.com, netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59002
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750926AbYD0FvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 01:51:13 -0400
In-Reply-To: <Pine.LNX.4.55.0804260059050.13902@cliff.in.clinika.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Sat, 26 Apr 2008 00:59:57 +0100 (BST)

> On Thu, 24 Apr 2008, David Miller wrote:
> 
> > From: Michael Beasley <youvegotmoxie@gmail.com>
> > Date: Thu, 24 Apr 2008 08:40:09 -0400
> > 
> > > From: Michael Beasley <youvegotmoxie@gmail.com>
> > > 
> > > Two is used in the wrong context here, as you are connecting to an IPv6 network
> > > over IPv4; not connecting two IPv6 networks to an IPv4 one.
> > > 
> > > Signed-off-by: Michael Beasley <youvegotmoxie@gmail.com>
> > 
> > Applied, thanks Michael.
> 
>  Please revert, the change is wrong as described in my other mail.

Done, thanks.
