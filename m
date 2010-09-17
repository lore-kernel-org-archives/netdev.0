From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 4/4] stmmac: use one memset() to reset TDES01
Date: Fri, 17 Sep 2010 16:13:37 -0700 (PDT)
Message-ID: <20100917.161337.200116262.davem@davemloft.net>
References: <1284729822-29176-2-git-send-email-peppe.cavallaro@st.com>
	<1284729822-29176-3-git-send-email-peppe.cavallaro@st.com>
	<1284729822-29176-4-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54664
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751936Ab0IQXNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 19:13:18 -0400
In-Reply-To: <1284729822-29176-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 17 Sep 2010 15:23:42 +0200

> Use one memset() to reset all TDES01 fields instead
> of one by one to reduce number of instructions.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
