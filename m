From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: act200: fix MODULE_PARM_DESC() typo
Date: Fri, 08 Jan 2016 13:24:55 -0500 (EST)
Message-ID: <20160108.132455.1028143073335198363.davem@davemloft.net>
References: <20160108105850.GD32195@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60553 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755897AbcAHSY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 13:24:59 -0500
In-Reply-To: <20160108105850.GD32195@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 8 Jan 2016 13:58:50 +0300

> There is no "membase", it was "act_port" that was intended.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
