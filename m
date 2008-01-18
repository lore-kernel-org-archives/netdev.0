From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Pull request for 'ipg-fixes' branch (try #2)
Date: Fri, 18 Jan 2008 14:39:34 -0500
Message-ID: <47910076.9010707@garzik.org>
References: <20080117223651.GA7782@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux@horizon.com,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Sorbica@icplus.com.tw, Jesse@icplus.com.tw,
	craig_rich@sundanceti.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52208 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753689AbYARTjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 14:39:44 -0500
In-Reply-To: <20080117223651.GA7782@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Please pull from branch 'ipg-fixes' in repository
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git ipg-fixes
> 
> to get the changes below.
> 
> Distance from 'master' (d8c89eb3a12f0da96d049bd515c7fa3702e511c5)
> -----------------------------------------------------------------
> 
> 47cccd7d7cc1f2b6f34aadc9041fb991c6293cdd
> dafdec746f8c468bebf6b99f32a392ee6c8d0212
> 0da1b995aee447656c0eb77e4e32468e37f868a3
> 227bc24d675d80de1cfb3ab72891cc932dadbc3b
> 
> Diffstat
> --------
> 
>  drivers/net/ipg.c |   36 ++++++++++++------------------------
>  1 files changed, 12 insertions(+), 24 deletions(-)
> 
> Shortlog
> --------
> 
> Francois Romieu (4):
>       ipg: balance locking in irq handler
>       ipg: plug Tx completion leak
>       ipg: fix queue stop condition in the xmit handler
>       ipg: fix Tx completion irq request

pulled


