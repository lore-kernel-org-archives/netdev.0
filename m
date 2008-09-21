From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: net: Use hton[sl]() was Re: [PATCH 10/14] Phonet:
 Phonet datagram transport protocol
Date: Sat, 20 Sep 2008 22:21:51 -0700 (PDT)
Message-ID: <20080920.222151.90057082.davem@davemloft.net>
References: <20080916170644.GM8702@ghostprotocols.net>
	<200809190933.33638.remi.denis-courmont@nokia.com>
	<20080919152448.GB29403@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54776
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751119AbYIUFWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 01:22:03 -0400
In-Reply-To: <20080919152448.GB29403@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 19 Sep 2008 12:24:48 -0300

> David, the following patch converts what is in net-next-2.6 net/ now:
 ...
>     net: Use hton[sl]() instead of __constant_hton[sl]() where applicable
>     
>     Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied, thanks Arnaldo.
