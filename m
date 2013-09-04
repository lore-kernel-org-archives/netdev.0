From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch] sfc: check for allocation failure
Date: Wed, 4 Sep 2013 15:41:18 +0100
Message-ID: <1378305678.1556.2.camel@bwh-desktop.uk.level5networks.com>
References: <20130902082828.GA30037@elgon.mountain>
	 <20130903.224939.866623192858217581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38527 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934495Ab3IDOly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 10:41:54 -0400
In-Reply-To: <20130903.224939.866623192858217581.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 22:49 -0400, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Mon, 2 Sep 2013 12:04:42 +0300
> 
> > It upsets static analyzers when we don't check for allocation failure.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> This applies cleanly neither to net nor net-next, please send me a
> version that does.

Oh yes, I failed to spot the filename.  That function has since been
moved to falcon.c.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
