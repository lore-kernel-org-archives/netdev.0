From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] stmmac: do not fail when the timer cannot be used.
Date: Mon, 23 Nov 2009 10:38:25 -0800 (PST)
Message-ID: <20091123.103825.264873517.davem@davemloft.net>
References: <1258966796-6602-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35528
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754858AbZKWSiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 13:38:08 -0500
In-Reply-To: <1258966796-6602-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 23 Nov 2009 09:59:56 +0100

> If the external timer cannot be used the driver
> will continue to work without mitigation.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Also applied to net-2.6
