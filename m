From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] stmmac: fix open funct when exit on error
Date: Mon, 11 Apr 2011 12:56:33 -0700 (PDT)
Message-ID: <20110411.125633.71120970.davem@davemloft.net>
References: <1302513406-3758-1-git-send-email-peppe.cavallaro@st.com>
	<1302513406-3758-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shiraz.hashim@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53185
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755764Ab1DKT5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 15:57:08 -0400
In-Reply-To: <1302513406-3758-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 11 Apr 2011 11:16:45 +0200

> This patch reviews the open function and fixes some
> errors when exit with an error state.
> It also moves the request_irq after core is initialized
> when interrupts are properly masked.
> 
> Signed-off-by: Shiraz Hashim <shiraz.hashim@st.com>
> Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
