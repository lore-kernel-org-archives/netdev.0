From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/3] myri10ge updates
Date: Mon, 11 Jun 2007 20:25:04 +0200
Message-ID: <466D9380.7090605@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1939 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753511AbXFKSYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 14:24:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Here are 3 minor updates of myri10ge for 2.6.22. The first one is a
reduced version of the earlier nacked patch, it now limits the number of
recoveries (to detect bad nics) without making the limit tunable.

1. limit the number of recoveries
2. report when the link partner is running in Myrinet mode
3. update driver version

Please apply.
Thanks!
Brice

