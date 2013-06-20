From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] sh_eth: cleanup 'enum TD_STS_BIT'
Date: Wed, 19 Jun 2013 17:04:03 -0700 (PDT)
Message-ID: <20130619.170403.1422018346775752902.davem@davemloft.net>
References: <201306200226.15228.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935383Ab3FTAEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 20:04:04 -0400
In-Reply-To: <201306200226.15228.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 20 Jun 2013 02:26:14 +0400

> Fix the comment to 'enum TD_STS_BIT', reformat the values, and add a couple of
> values missing before (though unused by the driver).
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
