From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: infiniband patch series (was Re: ipath patch series a-comin', but no IB maintainer to shepherd them)
Date: Tue, 11 Jul 2006 01:19:02 +0300
Message-ID: <20060710221902.GB32328@mellanox.co.il>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sean Hefty <sean.hefty@intel.com>,
	Roland Dreier <rolandd@cisco.com>, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxl145v65.mxlogic.net ([208.65.145.65]:56012 "EHLO
	p02c11o142.mxlogic.net") by vger.kernel.org with ESMTP
	id S965016AbWGJWSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 18:18:38 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting r. Michael S. Tsirkin <mst@mellanox.co.il>:
> Yes, -mm seems like a good way to get more review.

Andrew, am I using the right format to send things upstream to you?
There's really a set of independent patches, so it didn't make sense
to me to batch them up in a series. OK?
Maybe the addition of the git tree (below) serves to clarify things.

> Further, in the hope that this will help keep things reasonably stable till
> Roland comes back, and help everyone see what's being merged, I have
> created a git branch for all things infiniband going into 2.6.18.
> 
> You can get at it here:
> 	git://www.mellanox.co.il/~git/infiniband  mst-for-2.6.18

BTW, all outstanding infiniband patches intended for upstream are currently
there. Here's the list:

Jack Morgenstein:
      IB/mthca: fix mthca_ah_query static rate format

Michael S. Tsirkin:
      IB/cm: drop REQ when out of memory
      IB/mthca: comment fix

Sean Hefty:
      IB/addr: gid structure alignment fix

Vu Pham:
      IB/srp: fix fmr error handling

-- 
MST
