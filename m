From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] stmmac: nfs reboot crash & jumbo frame handling fix
Date: Mon, 09 Jul 2012 14:38:07 -0700 (PDT)
Message-ID: <20120709.143807.966872243639840388.davem@davemloft.net>
References: <1341818086-28897-1-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, spear--sw-devel@codex.cro.st.com,
	netdev@vger.kernel.org
To: deepak.sikri@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123Ab2GIViI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 17:38:08 -0400
In-Reply-To: <1341818086-28897-1-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Sikri <deepak.sikri@st.com>
Date: Mon, 9 Jul 2012 12:44:44 +0530

> This patch set handles in the fixes for following bugs that were
> observed during testing.
> 1. On Multiple reboot operations using nfs, system crash were observed
> with inconsistency in status of dma descriptors.
> 2. There were data losses observed whenever the jumbo frames were used
> for data transfers.
> 
> Deepak Sikri (2):
>   stmmac: Fix for nfs hang on multiple reboot
>   stmmac: Fix for higher mtu size handling

All applied, thanks.
