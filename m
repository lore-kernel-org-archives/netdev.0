From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] stmmac: use mdelay on timeout of sw reset
Date: Thu, 17 Nov 2011 03:13:59 -0500 (EST)
Message-ID: <20111117.031359.1436806550670179024.davem@davemloft.net>
References: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco.virlinzi@st.com,
	srinivas.kandagatla@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263Ab1KQIOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:14:07 -0500
In-Reply-To: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 17 Nov 2011 08:57:58 +0100

> From: Francesco Virlinzi <francesco.virlinzi@st.com>
> 
> This patch uses an mdelay to manage the timeout on
> sw reset to be independant of cpu_clk.
> 
> Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st.com>
> Reviewed-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
