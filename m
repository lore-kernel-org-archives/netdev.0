From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] net: icplus: fix interrupt mask
Date: Mon, 04 Jun 2012 12:03:05 -0400 (EDT)
Message-ID: <20120604.120305.1097852314226540702.davem@davemloft.net>
References: <1338825078-31856-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754607Ab2FDQDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 12:03:37 -0400
In-Reply-To: <1338825078-31856-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon,  4 Jun 2012 17:51:18 +0200

> This patch fixes the interrupt mask for IC101 A/G devices
> and now enables the link/speed/duplex interrupts.
> This is done by setting the "INTR pin used" bit and cleaning
> all the other bits in the Register 17.
> 
> Reported-by: Stuart Menefy <stuart.menefy@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
