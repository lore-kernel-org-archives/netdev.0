From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Allow administrative updates of inetpeer cache metrics
Date: Sat, 10 Mar 2012 12:06:04 -0500 (EST)
Message-ID: <20120310.120604.2169889346978923618.davem@davemloft.net>
References: <20120310134905.GA3703@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009Ab2CJRGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 12:06:12 -0500
In-Reply-To: <20120310134905.GA3703@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Herbert, look at Steffen Klassert's changes which went in two days
ago, they take care of this problem.
