From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] stmmac: fixed dma lib build when turn-on the debug
 option
Date: Mon, 11 Apr 2011 12:56:21 -0700 (PDT)
Message-ID: <20110411.125621.226773042.davem@davemloft.net>
References: <1302513406-3758-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53181
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755847Ab1DKT45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 15:56:57 -0400
In-Reply-To: <1302513406-3758-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 11 Apr 2011 11:16:44 +0200

> This patch fixes a compilation error when build the
> dwmac_lib with the DEBUG option enabled.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
