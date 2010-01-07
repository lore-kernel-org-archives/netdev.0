From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH] phy: SMSC device Energy Detect power-down mode
Date: Wed, 06 Jan 2010 20:35:24 -0800 (PST)
Message-ID: <20100106.203524.177114652.davem@davemloft.net>
References: <1262601873-7105-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53961
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752342Ab0AGEfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:35:15 -0500
In-Reply-To: <1262601873-7105-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon,  4 Jan 2010 11:44:33 +0100

> SMSC Ethernet Transceivers (LAN88710, LAN8710, LAN8720, LAN8187,
> LAN8700, LAN83C185) provide a mechanism to conserve power when
> the device is not connected to an active link partner
> (Energy Detect Mode).
> So this patch enables the Energy Detect power-down mode
> for these Transceivers.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied to net-next-2.6, thank you.
