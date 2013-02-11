From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 2/2] stmmac: mdio register has to fail if the
 phy is not found
Date: Sun, 10 Feb 2013 20:12:42 -0500 (EST)
Message-ID: <20130210.201242.868180034936117006.davem@davemloft.net>
References: <1360219672-27980-1-git-send-email-peppe.cavallaro@st.com>
	<1360219672-27980-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358Ab3BKBMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 20:12:43 -0500
In-Reply-To: <1360219672-27980-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu,  7 Feb 2013 07:47:52 +0100

> With this patch the stmmac fails in case of the phy device
> is not found; w/o this fix the mdio can be register twice when
> do down/up the iface and this is not correct.
> 
> Reported-by: Stas <stsp@list.ru>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
