From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: RE: [PATCH 03/11] IB/cm: Expose service ID in request events
Date: Mon, 15 Jun 2015 21:25:21 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FF59F8@ORSMSX109.amr.corp.intel.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-4-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Haggai Eran <haggaie@mellanox.com>,
	Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59057 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895AbbFOVZX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 17:25:23 -0400
In-Reply-To: <1434358036-15526-4-git-send-email-haggaie@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Expose the service ID on an incoming CM or SIDR request to the event
> handler. This will allow the RDMA CM module to de-multiplex connection
> requests based on the information encoded in the service ID.
> 
> Signed-off-by: Haggai Eran <haggaie@mellanox.com>

Acked-by: Sean Hefty <sean.hefty@intel.com>
