From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: cleanups in sock_setsockopt()
Date: Fri, 27 Apr 2012 02:14:55 -0400 (EDT)
Message-ID: <20120427.021455.220085630793882900.davem@davemloft.net>
References: <1335506879.2775.77.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab2D0GO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 02:14:58 -0400
In-Reply-To: <1335506879.2775.77.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Apr 2012 08:07:59 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Use min_t()/max_t() macros, reformat two comments, use !!test_bit() to
> match !!sock_flag()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Much better, applied.
