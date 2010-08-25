From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] stmmac: make ioaddr 'void __iomem *' rather than
 unsigned long
Date: Wed, 25 Aug 2010 16:31:11 -0700 (PDT)
Message-ID: <20100825.163111.232765010.davem@davemloft.net>
References: <1282632042-752-1-git-send-email-peppe.cavallaro@st.com>
	<1282632042-752-2-git-send-email-peppe.cavallaro@st.com>
	<1282632042-752-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40395
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752341Ab0HYXaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:30:55 -0400
In-Reply-To: <1282632042-752-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 24 Aug 2010 08:40:42 +0200

> This avoids unnecessary casting and adds the ioaddr in the
> private structure.
> This patch also removes many warning when compile the driver.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
