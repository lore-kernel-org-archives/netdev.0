From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 0/2] netxen fixes
Date: Fri, 16 Jan 2009 10:28:02 -0800
Message-ID: <1232130484-25188-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:54441 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757293AbZAPS2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2009 13:28:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One to fix build error when IPV6 is unset, other to fix a warning
on ppc64.


