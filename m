From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/10] cxgb3: Chelsio T3 1G/10G ethernet device driver
Date: Wed, 13 Dec 2006 21:40:39 -0800
Message-ID: <4580E3D7.3050708@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:8716 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbWLNGO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 01:14:58 -0500
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

I resubmit the patch supporting the latest Chelsio T3 adapter.
It incorporates the last feedbacks for code cleanup.
It is built gainst Linus'tree.

We think the driver is now ready to be merged.
Can you please advise on the next steps for inclusion in 2.6.20 ?

A corresponding monolithic patch is posted at the following URL:
http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

This driver is required by the Chelsio T3 RDMA driver
which was updated on 12/10/2006.

Cheers,
Divy

