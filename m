From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] fix typo in net/ipv6/Kconfig
Date: Sat, 26 Apr 2008 00:59:57 +0100 (BST)
Message-ID: <Pine.LNX.4.55.0804260059050.13902@cliff.in.clinika.pl>
References: <20080424084009.61f773a6@snafu.setup> <20080424.235043.152016786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: youvegotmoxie@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirk.serum.com.pl ([213.77.9.205]:64970 "EHLO serum.com.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757374AbYDZA4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 20:56:24 -0400
In-Reply-To: <20080424.235043.152016786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Apr 2008, David Miller wrote:

> From: Michael Beasley <youvegotmoxie@gmail.com>
> Date: Thu, 24 Apr 2008 08:40:09 -0400
> 
> > From: Michael Beasley <youvegotmoxie@gmail.com>
> > 
> > Two is used in the wrong context here, as you are connecting to an IPv6 network
> > over IPv4; not connecting two IPv6 networks to an IPv4 one.
> > 
> > Signed-off-by: Michael Beasley <youvegotmoxie@gmail.com>
> 
> Applied, thanks Michael.

 Please revert, the change is wrong as described in my other mail.

  Maciej
