From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/4] Pull request for 'sis190' branch
Date: Mon, 17 Dec 2007 18:18:17 -0500
Message-ID: <476703B9.7010604@garzik.org>
References: <20071210222732.GA8675@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"K.M. Liu" <kmliu@sis.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48930 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932403AbXLQXS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 18:18:26 -0500
In-Reply-To: <20071210222732.GA8675@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Please pull from branch 'sis190' in repository
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git sis190
> 
> to get the changes below.
> 
> Distance from 'upstream-linus' (7962024e9d16e9349d76b553326f3fa7be64305e)
> -------------------------------------------------------------------------
> 
> c27e14e508664471b8e44ef1f81ec080213ea314
> 348de67fe200e25d8cb80cff35642192436cfeda
> 004a22d03d62cd08e5287273a5143447db009cd0
> 14deb44ffe7220be2de697d616f28cce17e72297
> 
> Diffstat
> --------
> 
>  drivers/net/sis190.c |   21 ++++++++++-----------
>  1 files changed, 10 insertions(+), 11 deletions(-)
> 
> Shortlog
> --------
> 
> Francois Romieu (4):
>       sis190: add cmos ram access code for the SiS19x/968 chipset pair
>       sis190: remove duplicate INIT_WORK
>       sis190: mdio operation failure is not correctly detected
>       sis190: scheduling while atomic error

pulled into #upstream


