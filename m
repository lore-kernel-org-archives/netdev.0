From: David Miller <davem@davemloft.net>
Subject: Re: Is: automated testing before David M picks them up? Was: Re:
 [Xen-devel] [PATCH net v2] xen-netback: bookkeep number of active queues
 in our own module
Date: Fri, 27 Jun 2014 12:34:38 -0700 (PDT)
Message-ID: <20140627.123438.2145034024736949555.davem@davemloft.net>
References: <20140622.172105.1949118384610767695.davem@davemloft.net>
	<20140623084032.GU20819@zion.uk.xensource.com>
	<20140623153151.GA3261@laptop.dumpdata.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, boris.ostrovsky@oracle.com,
	ian.campbell@citrix.com, xen-devel@lists.xen.org,
	wei.liu2@citrix.com
To: konrad.wilk@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbaF0Tej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 15:34:39 -0400
In-Reply-To: <20140623153151.GA3261@laptop.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Mon, 23 Jun 2014 11:31:51 -0400

> Having said that - how do you handle such situation with sub-maintainers
> wanting to do some testing before they are cleared to go your way?

Who cares, the bug gets found eventually right?

There is no value in my letting changes sit for more than a day or two that
aren't being actively discussed and look fine to me.
