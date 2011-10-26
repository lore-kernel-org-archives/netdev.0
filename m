From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] stmmac: fix a bug while checking the HW cap reg
Date: Wed, 26 Oct 2011 17:23:24 -0400 (EDT)
Message-ID: <20111026.172324.225601012089445812.davem@davemloft.net>
References: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, keguang.zhang@gmail.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927Ab1JZVXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 17:23:31 -0400
In-Reply-To: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 26 Oct 2011 15:55:37 +0200

> The patch fixes a bug while checking the HW cap reg
> on old MAC10/100 where this feature is not available.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
