From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/13] remove code duplication in
 tcp_v[46]_conn_request
Date: Fri, 27 Jun 2014 15:54:24 -0700 (PDT)
Message-ID: <20140627.155424.1148874515273039754.davem@davemloft.net>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbaF0Wy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 18:54:27 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Wed, 25 Jun 2014 17:09:49 +0300

> This patch series unifies the TCPv4 and TCPv6 connection request flow
> in a single new function (tcp_conn_request).

Looks good, thanks for auditing the issue wrt. ipv4 mapped sockets.

Applied to net-next, thanks again.
