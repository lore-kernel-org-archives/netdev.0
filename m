From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] toshiba: Remove celleb from Kconfig options
Date: Tue, 14 Apr 2015 14:21:47 -0400 (EDT)
Message-ID: <20150414.142147.460840469991351107.davem@davemloft.net>
References: <1428989006-5929-1-git-send-email-dja@axtens.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	valentinrothberg@gmail.com, mpe@ellerman.id.au,
	linuxppc-dev@lists.ozlab.org
To: dja@axtens.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755121AbbDNSVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 14:21:50 -0400
In-Reply-To: <1428989006-5929-1-git-send-email-dja@axtens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Axtens <dja@axtens.net>
Date: Tue, 14 Apr 2015 15:23:24 +1000

> The toshiba drivers had celleb as an optional dependency.
> celleb has been dropped [1], so clean that out of Kconfig.
> 
> [1] http://patchwork.ozlabs.org/patch/451730/
> 
> CC: netdev@vger.kernel.org
> CC: Valentin Rothberg <valentinrothberg@gmail.com>
> CC: mpe@ellerman.id.au
> CC: linuxppc-dev@lists.ozlab.org
> Signed-off-by: Daniel Axtens <dja@axtens.net>

Applied, thanks.
