From: Jeff Garzik <jeff@garzik.org>
Subject: Re: - revert-8139too-clean-up-i-o-remapping.patch removed from -mm
 tree
Date: Sun, 16 Sep 2007 05:46:13 -0400
Message-ID: <46ECFB65.2070608@garzik.org>
References: <200709160927.l8G9R6cq009235@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: michal.k.k.piotrowski@gmail.com, netdev <netdev@vger.kernel.org>
To: akpm@linux-foundation.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40632 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752621AbXIPJqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Sep 2007 05:46:17 -0400
In-Reply-To: <200709160927.l8G9R6cq009235@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> The patch titled
>      revert "8139too: clean up I/O remapping"
> has been removed from the -mm tree.  Its filename was
>      revert-8139too-clean-up-i-o-remapping.patch
> 
> This patch was dropped because it was merged into mainline or a subsystem tree
> 
> ------------------------------------------------------
> Subject: revert "8139too: clean up I/O remapping"
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Revert git-netdev-all's 9ee6b32a47b9abc565466a9c3b127a5246b452e5.  Michal was
> getting oopses.
> 
> Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Shit!

Thanks for reminding me that I need to fix that up before it goes 
upstream with the rest of net-2.6.24.

	Jeff


