From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/3] more cleanups
Date: Thu, 05 Jan 2012 21:10:22 -0800
Message-ID: <20120106051022.712047093@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:35079 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750948Ab2AFFQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 00:16:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just found more places where function tables should be const.
