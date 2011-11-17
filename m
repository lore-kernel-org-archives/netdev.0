From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] stmmac: fix advertising 1000Base capabilties for
 non GMII iface
Date: Thu, 17 Nov 2011 03:14:07 -0500 (EST)
Message-ID: <20111117.031407.38499527507323234.davem@davemloft.net>
References: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
	<1321516682-32208-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco.virlinzi@st.com,
	srinivas.kandagatla@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574Ab1KQIOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:14:14 -0500
In-Reply-To: <1321516682-32208-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 17 Nov 2011 08:57:59 +0100

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> This patch fixes the way to stop the 1000Base advertising
> capabilties for non GMII interfaces.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
