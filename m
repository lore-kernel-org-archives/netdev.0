From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Add device IDs of blade version of the 82571 quad
 port
Date: Thu, 20 Sep 2007 17:41:39 -0400
Message-ID: <46F2E913.3080204@garzik.org>
References: <20070830182357.14185.69495.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33993 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297AbXITVll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 17:41:41 -0400
In-Reply-To: <20070830182357.14185.69495.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> This blade-specific board form factor is identical to the 82571EB
> board.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_ethtool.c |    1 +
>  drivers/net/e1000/e1000_hw.c      |    1 +
>  drivers/net/e1000/e1000_hw.h      |    1 +
>  drivers/net/e1000/e1000_main.c    |    2 ++
>  4 files changed, 5 insertions(+), 0 deletions(-)

I just found this buried in a dusty corner of my inbox.  is this still 
needed?

	Jeff



