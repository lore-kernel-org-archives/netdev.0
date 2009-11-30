From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [PATCH net-next-2.6 1/6] be2net: set netdev->vlan_features
 appropriately
Date: Mon, 30 Nov 2009 09:31:07 +0530
Message-ID: <20091130040106.GA14176@serverengines.com>
References: <20091130035444.GA15426@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:29608 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752960AbZK3EA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 23:00:58 -0500
Content-Disposition: inline
In-Reply-To: <20091130035444.GA15426@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/11/09 09:24 +0530, Ajit Khaparde wrote:
> patch to initialize netdev->vlan_features appropriately.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> ---
>  drivers/net/benet/be_main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)

Dave,
I waited for the following patch from Alexander Duyck to be accepted.
But since I did not see any activity on it, I sent my patch series
without considering that. Please let me know if you did not like it.

http://patchwork.ozlabs.org/patch/39265/

-Ajit
