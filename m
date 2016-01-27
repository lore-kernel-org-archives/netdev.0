From: David Miller <davem@davemloft.net>
Subject: Re: stable backport of 3 xen multiqueue network dev fixes
Date: Tue, 26 Jan 2016 17:44:12 -0800 (PST)
Message-ID: <20160126.174412.307182482674052748.davem@davemloft.net>
References: <1453377490.4320.16.camel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	wei.liu2@citrix.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com
To: ian.campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbcA0BoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 20:44:16 -0500
In-Reply-To: <1453377490.4320.16.camel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <ian.campbell@citrix.com>
Date: Thu, 21 Jan 2016 11:58:10 +0000

> Please could you queue these three:
> 
> 32a8440 xen-netfront: respect user provided max_queues
> 4c82ac3 xen-netback: respect user provided max_queues
> ca88ea1 xen-netfront: update num_queues to real created
> 
> for stable backports to at least 4.1. Multiqueue was added in v3.16 so I
> think they could all go to LTS that far back.

Done.
