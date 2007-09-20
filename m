From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/1] revert "8139too: clean up I/O remapping"
Date: Thu, 20 Sep 2007 16:58:43 -0400
Message-ID: <46F2DF03.1060501@garzik.org>
References: <200709202055.l8KKtWn3002075@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: michal.k.k.piotrowski@gmail.com, netdev <netdev@vger.kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41047 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219AbXITU6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 16:58:47 -0400
In-Reply-To: <200709202055.l8KKtWn3002075@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Revert git-netdev-all's 9ee6b32a47b9abc565466a9c3b127a5246b452e5.  Michal was
> getting oopses.
> 
> Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/8139too.c |   50 +++++++++++++++++++++++-----------------
>  1 file changed, 29 insertions(+), 21 deletions(-)

ACK -- DaveM, please remove or revert this patch.

It is incomplete, and not required just "nice to have."  I can easily 
recreate later.

	Jeff



