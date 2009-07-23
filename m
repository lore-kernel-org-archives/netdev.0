From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [net-next-2.6 PATCH][be2net] Add GRO support to the be2net
	driver. LRO is not supported anymore.
Date: Thu, 23 Jul 2009 11:48:26 +0530
Message-ID: <20090723061824.GE7646@serverengines.com>
References: <20090721120701.GA7570@serverengines.com> <20090721.123635.76413778.davem@davemloft.net>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:30825 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751127AbZGWGSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 02:18:21 -0400
Content-Disposition: inline
In-Reply-To: <20090721.123635.76413778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/07/09 12:36 -0700, David Miller wrote:
> From: Ajit Khaparde <ajitk@serverengines.com>
> Date: Tue, 21 Jul 2009 17:37:11 +0530
> 
> > 
> > This patch removes support for INET_LRO and switches over to GRO.
> >
> > Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> 
> Applied, thanks a lot for doing this work.

Dave, I just finished a git pull, but don't see the changes. 
What could be the reason?

-Ajit
