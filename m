From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [NET] Add constant for FCS/CRC length (frame check sequence)
Date: Mon, 21 May 2007 19:42:05 -0400
Message-ID: <46522E4D.6060000@garzik.org>
References: <20070515222916.9404.51955.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, auke@foo-projects.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46411 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756880AbXEUXmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 19:42:10 -0400
In-Reply-To: <20070515222916.9404.51955.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Auke Kok <auke-jan.h.kok@intel.com>
> 
> About a dozen drivers that have some form of crc checksumming or offloading
> use this constant, warranting a global define for it.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  include/linux/if_ether.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

applied


