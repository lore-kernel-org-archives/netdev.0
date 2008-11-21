From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: fix phy_id detection also for broken hardware.
Date: Thu, 20 Nov 2008 20:43:26 -0800 (PST)
Message-ID: <20081120.204326.138127709.davem@davemloft.net>
References: <1227196656-4361-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, giulio.benetti@micronovasrl.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36711
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752625AbYKUEn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 23:43:26 -0500
In-Reply-To: <1227196656-4361-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 20 Nov 2008 16:57:36 +0100

> This patch fixes the case when the phy_ids is mostly Fs and in some case 0x0
> due to broken hardware.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
