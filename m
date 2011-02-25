From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 29712] New: Bonding Driver(version : 3.5.0) -
 Problem with ARP monitoring in active backup mode
Date: Fri, 25 Feb 2011 10:54:17 -0800 (PST)
Message-ID: <20110225.105417.112602766.davem@davemloft.net>
References: <20110224145129.f366b59e.akpm@linux-foundation.org>
	<4D672525.5080609@hp.com>
	<E351E450E8B9F54684A699D42DC5ADF210062FA2@MPBAGVEX02.corp.mphasis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, akpm@linux-foundation.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	fubar@us.ibm.com
To: Harsha.R02@mphasis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50000
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756643Ab1BYSxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 13:53:40 -0500
In-Reply-To: <E351E450E8B9F54684A699D42DC5ADF210062FA2@MPBAGVEX02.corp.mphasis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Harsha R02" <Harsha.R02@mphasis.com>
Date: Fri, 25 Feb 2011 18:14:32 +0530

> Attached patch resolves the issue. Failover happened back to primary
> when it was up again in both the point to point and switch
> configuration.
> 
> Please let us know if this change can be included.

Please don't base64 encode your patches, that makes them harder
to read for some people.  It's just plain text.
