From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCH 1/3] xen-netback: fix license ident used in
 MODULE_LICENSE
Date: Fri, 22 Jan 2016 13:00:10 -0800 (PST)
Message-ID: <20160122.130010.1969101813739677626.davem@davemloft.net>
References: <20160122134943.GB1691@citrix.com>
	<1453472147.4320.92.camel@citrix.com>
	<20160122202521.76b98494@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	david.vrabel@citrix.com, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	boris.ostrovsky@oracle.com
To: gnomes@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39014 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379AbcAVVAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 16:00:14 -0500
In-Reply-To: <20160122202521.76b98494@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Date: Fri, 22 Jan 2016 20:25:21 +0000

>> The fact what include/linux/license.h:license_is_gpl_compatible includes
>> "Dual MIT/GPL" as an option seems to suggest that it is enough of a thing
>> to be validly used as the contents of a MODULE_LICENSE() thing.
> 
> Yes. The MIT licence most definitely exists, and people know what it
> means.
> 
> Also nobody should be changing the licence on anything unless they have
> the written permission of all rights holders on record, so it's best to
> leave it be 8)

+1
