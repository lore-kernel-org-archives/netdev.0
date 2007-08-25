From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] e1000e: retire last_tx_tso workaround
Date: Sat, 25 Aug 2007 03:49:54 -0400
Message-ID: <46CFDF22.9010102@garzik.org>
References: <20070822150839.19918.86665.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com,
	akpm@linux-foundation.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42065 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756189AbXHYHt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 03:49:59 -0400
In-Reply-To: <20070822150839.19918.86665.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> This TSO-related workaround is no longer needed since it's only
> applicable for 8254x silicon.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/e1000.h  |   15 +++------------
>  drivers/net/e1000e/netdev.c |   20 ++------------------
>  2 files changed, 5 insertions(+), 30 deletions(-)

applied 1-3 to #e1000e


