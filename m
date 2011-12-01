From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv6 : mcast : Delete useless parameter in
 ip6_mc_add1_src()
Date: Wed, 30 Nov 2011 23:17:32 -0500 (EST)
Message-ID: <20111130.231732.1077907260616772902.davem@davemloft.net>
References: <1322670065-13237-1-git-send-email-mypopydev@gmail.com>
	<1322670065-13237-2-git-send-email-mypopydev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mypopydev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab1LAERe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:17:34 -0500
In-Reply-To: <1322670065-13237-2-git-send-email-mypopydev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jun Zhao <mypopydev@gmail.com>
Date: Thu,  1 Dec 2011 00:21:05 +0800

> Need not to used 'delta' flag when add single-source to interface
> filter source list.
> 
> Signed-off-by: Jun Zhao <mypopydev@gmail.com>

Applied.
