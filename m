From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf_dbg: do not initialise statics to 0
Date: Thu, 11 Feb 2016 04:25:14 -0500 (EST)
Message-ID: <20160211.042514.673778753879277645.davem@davemloft.net>
References: <1454578583-4722-1-git-send-email-tangwei@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tangwei@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbcBKJZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 04:25:20 -0500
In-Reply-To: <1454578583-4722-1-git-send-email-tangwei@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Tang <tangwei@cmss.chinamobile.com>
Date: Thu,  4 Feb 2016 17:36:23 +0800

> This patch fixes the checkpatch.pl error to bpf_dbg.c:
> 
> ERROR: do not initialise statics to 0
> 
> Signed-off-by: Wei Tang <tangwei@cmss.chinamobile.com>

Applied, thanks.
