From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] l2tp: calling the ref() instead of deref()
Date: Fri, 22 Mar 2013 14:39:50 -0400 (EDT)
Message-ID: <20130322.143950.1823890736719486695.davem@davemloft.net>
References: <20130322183314.GA23163@longonot.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, tparkin@katalix.com, edumazet@google.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	kbuild@01.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754565Ab3CVSj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 14:39:56 -0400
In-Reply-To: <20130322183314.GA23163@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 22 Mar 2013 21:33:15 +0300

> This is a cut and paste typo.  We call ->ref() a second time instead
> of ->deref().
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
