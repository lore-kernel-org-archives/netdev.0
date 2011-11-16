From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/6] sky2 patches for net-next
Date: Wed, 16 Nov 2011 15:42:54 -0800
Message-ID: <20111116234254.319625694@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:48425 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754151Ab1KPXwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 18:52:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This includes fix for recent regression and other bug fixes (in order
of decreasing importance). Only the first one is critical to get
into 3.2.
