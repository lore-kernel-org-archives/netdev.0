From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] stmmac: fix pm functions avoiding sleep on spinlock
Date: Thu, 17 Nov 2011 03:14:35 -0500 (EST)
Message-ID: <20111117.031435.135947396579998865.davem@davemloft.net>
References: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
	<1321516682-32208-5-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco.virlinzi@st.com,
	srinivas.kandagatla@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661Ab1KQIOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:14:42 -0500
In-Reply-To: <1321516682-32208-5-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 17 Nov 2011 08:58:02 +0100

> From: Francesco Virlinzi <francesco.virlinzi@st.com>
> 
> This patch fixes the pm functions to avoid the system
> sleeps while a spinlock is taken.
> 
> Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
