From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] stmmac: remove dead option in the driver's Kconfig
Date: Wed, 25 Aug 2010 16:31:06 -0700 (PDT)
Message-ID: <20100825.163106.70211110.davem@davemloft.net>
References: <1282632042-752-1-git-send-email-peppe.cavallaro@st.com>
	<1282632042-752-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752207Ab0HYXau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:30:50 -0400
In-Reply-To: <1282632042-752-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 24 Aug 2010 08:40:41 +0200

> This patch removes the CPU_SUBTYPE_ST40 dependency in the
> driver's Kconfig.
> In fact, this option has been removed in the commit:
>  f96691872439ab2071171d4531c4a95b5d493ae5
> as reported by Christian Dietrich.
> 
> Note that the driver remains tested on STM platforms, only.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
