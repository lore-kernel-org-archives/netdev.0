From: "Latif, Faisal" <faisal.latif@intel.com>
Subject: RE: [PATCH 3/9] IB: nes: convert to SKB paged frag API.
Date: Thu, 25 Aug 2011 08:33:53 -0700
Message-ID: <2EFBCAEF10980645BBCFB605689E08E904E6C67786@azsmsx506.amr.corp.intel.com>
References: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
 <1314260895-15936-3-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Roland Dreier <roland@kernel.org>,
	"Hefty, Sean" <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:24142 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753292Ab1HYPd6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 11:33:58 -0400
In-Reply-To: <1314260895-15936-3-git-send-email-ian.campbell@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Acked-by: Faisal Latif <faisal.latif@intel.com>

Thanks.

> ---
>  drivers/infiniband/hw/nes/nes_nic.c |   21 +++++++++++----------
>  1 files changed, 11 insertions(+), 10 deletions(-)
