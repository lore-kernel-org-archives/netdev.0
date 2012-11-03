From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ptp: fixup Kconfig for two PHC drivers.
Date: Sat, 03 Nov 2012 15:37:51 -0400 (EDT)
Message-ID: <20121103.153751.874328618004349309.davem@davemloft.net>
References: <1351850258-5072-1-git-send-email-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754850Ab2KCThx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:37:53 -0400
In-Reply-To: <1351850258-5072-1-git-send-email-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri,  2 Nov 2012 10:57:38 +0100

> Ben Hutchings recently came up with a better way to handle the kconfig
> dependencies for the PTP hardware clocks. This patch converts one new and
> one older driver to the new scheme.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied.
