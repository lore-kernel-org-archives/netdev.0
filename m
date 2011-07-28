From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2] bonding: reduce noise during init
Date: Wed, 27 Jul 2011 22:40:02 -0700 (PDT)
Message-ID: <20110727.224002.381070158903814963.davem@davemloft.net>
References: <11239.1311727039@death>
	<1311727227.15386.40.camel@Joe-Laptop>
	<20110727200926.GS21309@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, fubar@us.ibm.com, netdev@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754804Ab1G1FmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:42:06 -0400
In-Reply-To: <20110727200926.GS21309@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 27 Jul 2011 16:09:26 -0400

> Subject: [PATCH net-next-2.6 v2] bonding: reduce noise during init
> 
> Many are using sysfs to configure bonding rather than module options, so
> there is no need for bonding to throw this warning in normal cases.
> 
> Keep the message around when debugging is enabled as it might be useful
> for someone desperate enough to enable debugging, but eliminate it
> otherwise.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Applied.
