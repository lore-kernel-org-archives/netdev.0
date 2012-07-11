From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch -next] net: writes past the end of the struct
Date: Wed, 11 Jul 2012 11:37:40 +0300
Message-ID: <20120711083740.GC6056@mwanda>
References: <20120711063214.GA11812@elgon.mountain>
 <20120711.012745.2202204429130083377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:26228 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756870Ab2GKIie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 04:38:34 -0400
Content-Disposition: inline
In-Reply-To: <20120711.012745.2202204429130083377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 11, 2012 at 01:27:45AM -0700, David Miller wrote:
> I asked him to fix some things, he did too much casting, but he never
> respun his patch set.  I definitely prefer this gets fixed his way.
> 

Oooo.  That's a clever trick.  Nice.

regards,
dan carpenter
