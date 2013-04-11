From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: prevent interrupt loop with MMC RX IPC Counter
Date: Thu, 11 Apr 2013 16:03:44 -0400 (EDT)
Message-ID: <20130411.160344.1137842208699027001.davem@davemloft.net>
References: <511E51A9.9020908@st.com>
	<1365580564-9149-1-git-send-email-christian.ruppert@abilis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: christian.ruppert@abilis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487Ab3DKUDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 16:03:47 -0400
In-Reply-To: <1365580564-9149-1-git-send-email-christian.ruppert@abilis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Ruppert <christian.ruppert@abilis.com>
Date: Wed, 10 Apr 2013 09:56:04 +0200

> If the DesignWare MAC is synthesised with MMC RX IPC Counter, an unmanaged
> and unacknowledged interrupt is generated after some time of operation.
> 
> This patch masks the undesired interrupts.
> 
> Signed-off-by: Christian Ruppert <christian.ruppert@abilis.com>
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
