From: Joe Perches <joe@perches.com>
Subject: [rfc] Creating drivers/net/ethernet
Date: Fri, 07 Jan 2011 13:15:18 -0800
Message-ID: <1294434918.17763.39.camel@Joe-Laptop>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jeffrey Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3021 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753582Ab1AGVPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 16:15:20 -0500
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does anyone still think moving files around in drivers/net
would be sensible and a suitable candidate for 2.6.38?

http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf

Here's what I proposed.

http://www.spinics.net/lists/netdev/msg149717.html

I agree with Jan that the current 10/100, 1000, 10000 speed
selections mechanisms are less than ideal.

Perhaps it'd be worthwhile to remove it.

