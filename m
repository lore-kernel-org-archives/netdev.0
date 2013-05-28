From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] net: phy: fix a bug when verify the EEE
 support
Date: Mon, 27 May 2013 23:30:28 -0700 (PDT)
Message-ID: <20130527.233028.2170050655919532993.davem@davemloft.net>
References: <1369639888-11805-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933008Ab3E1Ga2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:30:28 -0400
In-Reply-To: <1369639888-11805-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 27 May 2013 09:31:28 +0200

> The phy_init_eee has to exit with an error when the
> local device and its link partner both do not support EEE.
> So this patch fixes a problem when verify this.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
