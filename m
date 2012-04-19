From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] icplus: fix interrupt for IC+ 101A/G and 1001LF
Date: Thu, 19 Apr 2012 15:34:41 -0400 (EDT)
Message-ID: <20120419.153441.1815697413007824890.davem@davemloft.net>
References: <1334733400-29340-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958Ab2DSTeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 15:34:46 -0400
In-Reply-To: <1334733400-29340-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 18 Apr 2012 09:16:40 +0200

> This patch fixes and adds the irq handler for the
> IC+ 101A/G where we need to read the reg17 to clean
> the irq.
> Also remove the flag for the 1001LF where no interrupt
> can be used for this device.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
