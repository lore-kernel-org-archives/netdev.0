From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix sparse warning for sctp_init_cause_fixed
Date: Mon, 16 Jul 2012 23:24:02 -0700 (PDT)
Message-ID: <20120716.232402.2125169265661605899.davem@davemloft.net>
References: <1342199797-11305-1-git-send-email-ioanorghici@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, sri@us.ibm.com, netdev@vger.kernel.org
To: ioanorghici@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907Ab2GQGYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 02:24:03 -0400
In-Reply-To: <1342199797-11305-1-git-send-email-ioanorghici@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ioan Orghici <ioanorghici@gmail.com>
Date: Fri, 13 Jul 2012 20:16:37 +0300

> Fix the following sparse warning:
> 	* symbol 'sctp_init_cause_fixed' was not declared. Should it be
> 	  static?
> 
> Signed-off-by: Ioan Orghici <ioanorghici@gmail.com>

Applied.
