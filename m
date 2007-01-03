From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: [PATCH  v4 01/13] Linux RDMA Core Changes
Date: Wed, 3 Jan 2007 17:02:30 +0200
Message-ID: <20070103150230.GP6019@mellanox.co.il>
References: <1167836172.4187.9.camel@stevo-desktop>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dev.mellanox.co.il ([194.90.237.44]:36498 "EHLO
	dev.mellanox.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbXACPEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 10:04:24 -0500
To: Steve Wise <swise@opengridcomputing.com>
Content-Disposition: inline
In-Reply-To: <1167836172.4187.9.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I've run this code with mthca and didn't notice any performance
> degradation, but I wasn't specifically measuring cq_poll overhead in a
> tight loop...

We were speaking about ib_req_notify_cq here, actually, not cq poll.
So what was tested?

-- 
MST
