From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/3] cxgb3 driver update
Date: Wed, 22 Aug 2007 23:35:20 -0700
Message-ID: <46CD2AA8.9070507@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:4598 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbXHWGgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 02:36:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

I'm submitting three more patches for inclusion in netdev#upstream.
These patches are built over the series I resent yesterday night.
The patch numbering reflects the stacking.

Here is a brief description:
-   avoid false positives in the xgmac hang workaround
-   Properly set the CQ_ERR bit in RDMA CQ contexts.
-   Update CQ context operations time out values

Cheers,
Divy


