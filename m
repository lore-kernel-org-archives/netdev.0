From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] stmmac: review the wake-up support
Date: Fri, 24 Sep 2010 21:27:50 -0700 (PDT)
Message-ID: <20100924.212750.200377875.davem@davemloft.net>
References: <1285151906-14190-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33650
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753985Ab0IYE1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 00:27:30 -0400
In-Reply-To: <1285151906-14190-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 22 Sep 2010 12:38:26 +0200

> If the PM support is available this is passed
> through the platform instead to be hard-coded
> in the core files.
> WoL on Magic Frame can be enabled by using
> the ethtool support.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
