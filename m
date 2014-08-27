From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] phy: fix EEE checks inside the phy_init_eee.
Date: Wed, 27 Aug 2014 16:30:13 -0700 (PDT)
Message-ID: <20140827.163013.2147385753856195294.davem@davemloft.net>
References: <1409038012-11574-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nandini.sharma@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41760 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936043AbaH0XaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 19:30:13 -0400
In-Reply-To: <1409038012-11574-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 26 Aug 2014 09:26:52 +0200

> According to the Std 802.3az if the EEE Adv (Reg 7.60), Link partner ability
> (Reg 7.61) and EEE capability (Register 3.20) bits return 0 this  means no EEE
> is supported. So this patch fixes the checks inside the phy_init_eee function.
> 
> Signed-off-by: Nandini Sharma <nandini.sharma@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
