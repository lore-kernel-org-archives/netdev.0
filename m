From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] qlge: Replacing add_timer() to mod_timer()
Date: Fri, 02 Jul 2010 21:59:25 -0700 (PDT)
Message-ID: <20100702.215925.193715679.davem@davemloft.net>
References: <e687077281d05d3a2da49431b7c0ff0b1076f3e6.1277936929.git.root@sanx1002.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48983
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751749Ab0GCE7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 00:59:12 -0400
In-Reply-To: <e687077281d05d3a2da49431b7c0ff0b1076f3e6.1277936929.git.root@sanx1002.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Thu,  1 Jul 2010 10:00:17 -0300

> Currently qlge driver calls add_timer() instead of mod_timer().
> This patch changes add_timer() to mod_timer(), which seems a better
> solution.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
