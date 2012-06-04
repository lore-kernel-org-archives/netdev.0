From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git (v2)] stmmac: remove two useless initialisations
Date: Mon, 04 Jun 2012 14:12:01 -0400 (EDT)
Message-ID: <20120604.141201.1031950564719192962.davem@davemloft.net>
References: <1338827782-11877-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455Ab2FDSMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 14:12:02 -0400
In-Reply-To: <1338827782-11877-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon,  4 Jun 2012 18:36:22 +0200

> This patch removes two useless initialisations in the
> stmmac_rx and stmmac_tx functions.
> In the former, the count variable was reset twice and in
> the stmmac_tx we only need to increment the dirty pointer
> w/o setting the entry variable.
> 
> v2: review the subject and comment that was not clear in my
> first version.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
