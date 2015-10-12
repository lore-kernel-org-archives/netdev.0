From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [PATCH for-next 0/2]  RDMA/cxgb4: Add iWARP support for T6 adapter
Date: Mon, 12 Oct 2015 12:01:58 -0500
Message-ID: <003201d1050f$b4b7d590$1e2780b0$@opengridcomputing.com>
References: <1443008967-8942-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <dledford@redhat.com>, <davem@davemloft.net>, <leedom@chelsio.com>,
	<nirranjan@chelsio.com>
To: "'Hariprasad Shenai'" <hariprasad@chelsio.com>,
	<linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:41959 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751467AbbJLRB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 13:01:57 -0400
In-Reply-To: <1443008967-8942-1-git-send-email-hariprasad@chelsio.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Hariprasad Shenai
> Sent: Wednesday, September 23, 2015 6:49 AM
> To: linux-rdma@vger.kernel.org; netdev@vger.kernel.org
> Cc: dledford@redhat.com; davem@davemloft.net; swise@opengridcomputing.com; leedom@chelsio.com; nirranjan@chelsio.com;
> Hariprasad Shenai
> Subject: [PATCH for-next 0/2] RDMA/cxgb4: Add iWARP support for T6 adapter
> 
> Hi,
> 
> PATCH 1/2 adds changes like new register, structure and functions in cxgb4
> driver for iw_cxgb4 driver, and PATCH 2/2 adds iw_cxgb4 specific code to
> support T6 adapter.
> 
> This patch series has been created against Doug's linux tree and includes
> patches on cxgb4 and iw_cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.
> 
> Thanks
> 

These look ok to me. 

Series Reviewed-by: Steve Wise <swise@opengridcomputing.com>

Doug, should these get staged through your tree?

Steve.
