From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IB/rds: suppress incompatible protocol when
 version is known
Date: Wed, 26 Dec 2012 15:18:10 -0800 (PST)
Message-ID: <20121226.151810.1691248733680271193.davem@davemloft.net>
References: <20121221175857.23716.46975.stgit@phlsvslse11.ph.intel.com>
	<20121221180154.23716.44540.stgit@phlsvslse11.ph.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, linux-rdma@vger.kernel.org,
	roland@kernel.org, rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: mike.marciniszyn@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab2LZXSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 18:18:11 -0500
In-Reply-To: <20121221180154.23716.44540.stgit@phlsvslse11.ph.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Marciniszyn <mike.marciniszyn@intel.com>
Date: Fri, 21 Dec 2012 13:01:54 -0500

> Add an else to only print the incompatible protocol message
> when version hasn't been established.
> 
> Signed-off-by: Mike Marciniszyn <mike.marciniszyn@intel.com>

Applied.
