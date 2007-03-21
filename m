From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/5] netem performance improvements
Date: Wed, 21 Mar 2007 10:42:31 -0700
Message-ID: <20070321174231.890361963@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46919 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607AbXCUR6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 13:58:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches for the 2.6.22 net tree, increase the
performance of netem by about 2x.  With 2.6.20 getting about
100K (out of possible 300K) packets per second, after these
patches now at over 200K pps.

-- 

