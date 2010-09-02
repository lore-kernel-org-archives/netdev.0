From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next 0/4] cxgb3: new code to deal with adapter parity errors
Date: Thu, 2 Sep 2010 16:04:28 -0700
Message-ID: <241D2F16-4F92-48DD-A904-832771B2F4B4@chelsio.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1118 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193Ab0IBXE3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 19:04:29 -0400
Received: from [10.192.173.71] ([10.192.173.71])
	by stargate.chelsio.com (8.13.1/8.13.1) with ESMTP id o82N4STJ001946
	for <netdev@vger.kernel.org>; Thu, 2 Sep 2010 16:04:28 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  These patches implement code to detect and recover from adapter parity errors.

  Two of the following four patches (2/4 and 3/4) were actually implemented by Dimitris Michailidis just before he headed off for vacation.  I've indicated that via a "Signed-off-by" by-line for him as well as one for me which I _think_ is the right way to do this.  The other two patches (1/4 and 4/4) were implemented by me so I've only included a "Signed-off-by" for me on those.  If I've done anything incorrectly please reject the patches and tell me how to correct them.  Thanks!

Casey