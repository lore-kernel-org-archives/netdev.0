From: Byungho An <bh74.an@samsung.com>
Subject: RE: [net-next] stmmac: modified pcs mode support for SGMII
Date: Mon, 08 Apr 2013 12:56:01 +0900
Message-ID: <015601ce340c$fc126940$f4373bc0$%an@samsung.com>
References: <00b401ce30f9$3a628c50$af27a4f0$%an@samsung.com>
 <20130407.170846.2105935127378498264.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	kgene.kim@samsung.com, cpgs@samsung.com
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:27718 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934821Ab3DHD4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 23:56:03 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MKX00DQ049AELD0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 08 Apr 2013 12:56:02 +0900 (KST)
In-reply-to: <20130407.170846.2105935127378498264.davem@davemloft.net>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I fixed and resent this patch.

Thank you.

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, April 08, 2013 6:09 AM
> To: bh74.an@samsung.com
> Cc: netdev@vger.kernel.org; peppe.cavallaro@st.com; kgene.kim@samsung.com; cpgs@samsung.com
> Subject: Re: [net-next] stmmac: modified pcs mode support for SGMII
> 
> From: Byungho An <bh74.an@samsung.com>
> Date: Thu, 04 Apr 2013 14:57:01 +0900
> 
> > This patch modifies the pcs mode support for SGMII. Even though
> > SGMII does auto-negotiation with phy, it needs stmmac_init_phy and
> > stmmac_mdio_register function for initializing phy.
> >
> > Signed-off-by: Byungho An <bh74.an@samsung.com>
> 
> Your email client corrupted this patch, it turned all TAB characters
> into spaces.  This makes your submission unusable.
> 
> Please fix this, email the patch to yourself, and only resubmit the
> patch here if you are able to successfully apply the patch you receive
> in a test email.
