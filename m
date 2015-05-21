From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] stmmac: probe code refactoring and clean
 up part 1
Date: Thu, 21 May 2015 18:57:40 -0400 (EDT)
Message-ID: <20150521.185740.1825645288319421215.davem@davemloft.net>
References: <1432144989-28283-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org, arnd@arndb.de,
	linux-arm-kernel@lists.infradead.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbbEUW5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 18:57:42 -0400
In-Reply-To: <1432144989-28283-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Wed, 20 May 2015 20:03:05 +0200

> This patch set refactor the code in stmmac_pci_probe and stmmac_pltfr_probe
> and moves the common bits into stmmac_dvr_probe. Along the way some clean-
> ups are applied to stmmac_pltfr_probe.
> 
> The code has been tested on the LPC18xx platform.
> 
> I am still working on more refactoring of the platform probe code, hence
> part 1, but I need some more time on this.

Series applied, thank you.
