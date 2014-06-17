From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: move ir_mark initialization to
 tcp_openreq_init
Date: Tue, 17 Jun 2014 15:32:34 -0700 (PDT)
Message-ID: <20140617.153234.1346958850605351166.davem@davemloft.net>
References: <1402993537-6411-1-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966737AbaFQWce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 18:32:34 -0400
In-Reply-To: <1402993537-6411-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Tue, 17 Jun 2014 11:25:37 +0300

> ir_mark initialization is done for both TCP v4 and v6, move it in the
> common tcp_openreq_init function.
> 
> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>

Applied, thanks.
