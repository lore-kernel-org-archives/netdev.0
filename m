From: David Miller <davem@davemloft.net>
Subject: Re: You have to fix this
Date: Fri, 28 Sep 2012 13:43:13 -0400 (EDT)
Message-ID: <20120928.134313.2263654281720915031.davem@davemloft.net>
References: <20120927.183406.962014014858457666.davem@davemloft.net>
	<5065911A.3000509@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755144Ab2I1RnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 13:43:16 -0400
In-Reply-To: <5065911A.3000509@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Fri, 28 Sep 2012 17:29:22 +0530

> Please let me know how else would I get above warning message?

Maybe your compiler is too old.  Does -Wframe-larger-than= show up in your
build logs with "make V=1"?
