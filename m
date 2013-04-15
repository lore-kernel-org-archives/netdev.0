From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][nex-next] sis900: check for DMA map errors
Date: Mon, 15 Apr 2013 14:13:57 -0400 (EDT)
Message-ID: <20130415.141357.2008676366895676344.davem@davemloft.net>
References: <1366009889-2068-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092Ab3DOSN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 14:13:59 -0400
In-Reply-To: <1366009889-2068-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Mon, 15 Apr 2013 11:11:29 +0400

> The first backtrace appears on tx path with DMA mapping operations debug
> enabled.
 ...
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

Applied.
