From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git] stmmac: remove useless csum flag
Date: Wed, 21 Aug 2013 20:38:55 -0700 (PDT)
Message-ID: <20130821.203855.1340321358624283559.davem@davemloft.net>
References: <20130821.000600.1770175220773794518.davem@davemloft.net>
	<1377069074-4488-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sonic.zhang@analog.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465Ab3HVDjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 23:39:03 -0400
In-Reply-To: <1377069074-4488-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 21 Aug 2013 09:11:14 +0200

> This patch removes the no_csum_insertion private parameter that is not used anymore
> and, also,  the "likely" annotation from the condition that is not in a critical path.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Sonic Zhang <sonic.zhang@analog.com>

Applied, thanks.
