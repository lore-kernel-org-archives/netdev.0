From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 2/2] stmmac: set ptp_clock to NULL while
 unregister
Date: Mon, 25 Aug 2014 15:33:25 -0700 (PDT)
Message-ID: <20140825.153325.309527944583234120.davem@davemloft.net>
References: <1408971379-14871-1-git-send-email-peppe.cavallaro@st.com>
	<1408971379-14871-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148AbaHYWdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:33:25 -0400
In-Reply-To: <1408971379-14871-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Mon, 25 Aug 2014 14:56:19 +0200

> This is to properly put to NULL the ptp_clock while un-register the PTP support.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
