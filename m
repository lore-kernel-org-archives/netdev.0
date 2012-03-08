From: David Miller <davem@davemloft.net>
Subject: Re: [patch] atl1c: set ATL1C_WORK_EVENT_RESET bit correctly
Date: Thu, 08 Mar 2012 00:29:03 -0800 (PST)
Message-ID: <20120308.002903.2204810112948469308.davem@davemloft.net>
References: <20120307100204.GB25452@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, ian.campbell@citrix.com,
	eric.dumazet@gmail.com, jpirko@redhat.com, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754274Ab2CHIaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 03:30:17 -0500
In-Reply-To: <20120307100204.GB25452@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 7 Mar 2012 13:02:04 +0300

> ATL1C_WORK_EVENT_RESET is zero so the original code here is a nop.  The
> intent was to set the zero bit.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
