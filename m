From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: do not initialise statics to NULL
Date: Mon, 07 Mar 2016 11:09:18 -0500 (EST)
Message-ID: <20160307.110918.927174684494714776.davem@davemloft.net>
References: <1457332193-3182-1-git-send-email-tangwei@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul@paul-moore.com, netdev@vger.kernel.org
To: tangwei@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841AbcCGQJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:09:20 -0500
In-Reply-To: <1457332193-3182-1-git-send-email-tangwei@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Tang <tangwei@cmss.chinamobile.com>
Date: Mon,  7 Mar 2016 14:29:53 +0800

> This patch fixes the checkpatch.pl error to netlabel_domainhash.c:
> 
> ERROR: do not initialise statics to NULL
> 
> Signed-off-by: Wei Tang <tangwei@cmss.chinamobile.com>

Applied.
