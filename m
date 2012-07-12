From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [net-next:master 90/102] net/ipv4/route.c:1283:9: warning:
 unused variable 'saddr'
Date: Thu, 12 Jul 2012 18:47:58 +0300
Message-ID: <20120712154758.GF6056@mwanda>
References: <20120712143449.GA19890@localhost>
 <20120712.074058.753681400854318989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fengguang.wu@intel.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:20651 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932676Ab2GLPsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 11:48:13 -0400
Content-Disposition: inline
In-Reply-To: <20120712.074058.753681400854318989.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 12, 2012 at 07:40:58AM -0700, David Miller wrote:
> 
> There's not need to report these to kernel-janitors if it's a
> net-next specific issue and I'm going to fix it up 5 minutes
> after you report it.

The kernel-janitors list is CC'd to prevent people from sending
duplicate messages.  This has happened in the past and it's
annoying for everyone.

regards,
dan carpenter
