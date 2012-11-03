From: Vipul Pandya <vipul@chelsio.com>
Subject: Query regarding pushing a patch series against net-next tree
Date: Sat, 03 Nov 2012 13:18:48 +0530
Message-ID: <5094CC60.20907@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>,
	kumar Sanghvi <kumaras@chelsio.com>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitrios Michailidis <dm@chelsio.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6401 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393Ab2KCHz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 03:55:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David Miller,

We have a important patch series fixing a bug as well as adding a
feature. This patch series is prepared against net-next tree. However to
be able to build it successfully it requires a patch from net tree which
was pushed recently. So, we cannot push this patch series until both the
trees are merged. We would like this patch series to be submitted as
soon as possible to net-next so that it can be accepted by OFED community.

Can you please suggest how should we proceed for submitting this patch
series?

Thanks,
Vipul Pandya
