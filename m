From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Wed, 18 Apr 2012 17:51:12 +0300
Message-ID: <20120418145112.GC27101@mwanda>
References: <20120418064723.GA12831@elgon.mountain>
 <1334758394.3209.156.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tristram.Ha@micrel.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:28954 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887Ab2DROsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 10:48:43 -0400
Content-Disposition: inline
In-Reply-To: <1334758394.3209.156.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 18, 2012 at 03:13:14PM +0100, Ben Hutchings wrote:
> 
> The correct length is ETH_ALEN, as for the previous memcpy().

Thanks.  I'll send a patch for that.

regards,
dan carpenter
