From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] qed: Attention support patch series
Date: Tue, 01 Mar 2016 17:40:11 -0500 (EST)
Message-ID: <20160301.174011.1852663994206509014.davem@davemloft.net>
References: <1456655215-16345-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbcCAWkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:40:13 -0500
In-Reply-To: <1456655215-16345-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sun, 28 Feb 2016 12:26:51 +0200

> Until now we've only enabled attention generation for the sake of
> management firmware indications [required for link notifications].
> 
> This series enables [almost] all the attention sources of the HW,
> currently for the sake of logging information relating to issues
> experienced by HW. In future, infrastructure laid here would also be used
> for the sake of the recovery process.
> 
> The first patch in the series is a semantic alignemnt of the code.
> The later 3 patches incremently create said infrastructure and enrich
> the logged information.
> Notice #3 contains quite a bit of structures [consisting of ~1K lines]
> that will eventually be removed and incorporated in the binary fw file.

Series applied, thanks.
