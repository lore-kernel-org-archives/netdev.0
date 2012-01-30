From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: strip unused module code from
 sun3_82586.c
Date: Mon, 30 Jan 2012 12:55:53 -0500 (EST)
Message-ID: <20120130.125553.1915309230990176019.davem@davemloft.net>
References: <1327708546-30973-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sammy@sammy.net, netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382Ab2A3R4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 12:56:03 -0500
In-Reply-To: <1327708546-30973-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 27 Jan 2012 18:55:46 -0500

> This code is clearly unused, since it has a #error right
> in it.  Given the vintage of sun3 hardware, it is probably
> safe to assume that there is little interest in adding new
> functionality to the driver now, so just delete the unused
> block of code.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.
