From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Pull request for 'r6040' branch
Date: Mon, 11 Feb 2008 11:07:45 -0500
Message-ID: <47B072D1.70302@garzik.org>
References: <20080205223452.GA8361@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Florian Fainelli <florian.fainelli@telecomint.eu>,
	Sten Wang <sten.wang@rdc.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51660 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755038AbYBKQHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 11:07:49 -0500
In-Reply-To: <20080205223452.GA8361@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Please pull from branch 'r6040' in repository
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r6040
> 
> to get the changes below.
> 
> I have simply rebased the r6040 branch from december on top of
> Linus's latest head and given each patch a compile test.
> The content is identical to Florian's initial work (minus the
> removal of the unused TIMER_WUT and a duplicate update of an
> error counter).
> 
> Distance from 'master' (21511abd0a248a3f225d3b611cfabb93124605a7)
> -----------------------------------------------------------------
> 
> ec6d2d453a932fd50c5fd95d5aac633b4e5f241d
> 106adf3c84d081776a1d1fbb8a047cad12af2bb9
> b4f1255d6839bd970d5ff20a9c3d73f73c9adaa3
> d248fd77902fcf33b0bc49ab521930877d94890f
> 
> Diffstat
> --------
> 
>  drivers/net/r6040.c |  233 +++++++++++++++++++++++++++++---------------------
>  1 files changed, 135 insertions(+), 98 deletions(-)
> 
> Shortlog
> --------
> 
> Florian Fainelli (4):
>       r6040: do not use a private stats structure to store statistics
>       r6040: add helpers to allocate and free the Tx/Rx buffers
>       r6040: recover from transmit timeout
>       r6040: cleanups

pulled


