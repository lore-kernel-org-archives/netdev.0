From: Michael Wang <yun.wang@profitbricks.com>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport()
 for each HW
Date: Thu, 09 Apr 2015 14:42:24 +0200
Message-ID: <552673B0.7040500@profitbricks.com>
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com> <20150408201015.GB28666@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, Hal Rosenstock <hal.rosenstock@gmail.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Mike Marciniszyn <infinipath@intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Faisal Latif <faisal.latif@intel.com>,
	Upinder Malhi <umalhi@cisco.com>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ira Weiny <ira.weiny@intel.com>,
	PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
	Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Haggai Er
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34911 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbbDIMm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 08:42:29 -0400
Received: by wgyo15 with SMTP id o15so108057944wgy.2
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 05:42:28 -0700 (PDT)
In-Reply-To: <20150408201015.GB28666@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 10:10 PM, Jason Gunthorpe wrote:
[snip]
> 
> Some of the other checks in this file revolve around pkey, I'm not
> sure what rocee does there? cap_pkey_supported ?

I'm not sure if this count in capability... how shall we describe it?

Regards,
Michael Wang

> 
> Jason
> 
