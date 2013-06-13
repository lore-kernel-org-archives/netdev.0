From: 'Kukjin Kim' <kgene@kernel.org>
Subject: RE: [PATCH net-next] stmmac: added device tree support for fixed_phy
 and phy_addr
Date: Thu, 13 Jun 2013 21:08:06 +0900
Message-ID: <150a01ce682e$a9e95ab0$fdbc1010$@org>
References: <019301ce67d4$ed1e32b0$c75a9810$%an@samsung.com>
 <51B9989F.5020603@st.com> <01b201ce6820$640897d0$2c19c770$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: 'Byungho An' <bh74.an@samsung.com>,
	'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:17416 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214Ab3FMMIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 08:08:09 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MOB00CGRZ1JHF40@mailout2.samsung.com> for
 netdev@vger.kernel.org; Thu, 13 Jun 2013 21:08:07 +0900 (KST)
In-reply-to: <01b201ce6820$640897d0$2c19c770$%an@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Byungho An wrote:
> 
> 
> On 6/13/2013 7:04 PM, Giuseppe CAVALLARO wrote:
> > On 6/13/2013 3:25 AM, Byungho An wrote:
> > >
> > > This patch adds device tree support for fixed_phy and phy_addr it
> means
> > > fixed_phy and phy_addr can be set in device tree file. "fixed_phy" and
> > > "phy_addr" can be added in the device tree blob.
> >
> > concerning this, we had added some work to pass from the platform
> > the fixed bus name.
> >
> > http://git.stlinux.com/?p=stm/linux-
> >
> stm.git;a=blob;f=drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c;h=2
> d540e1d2151e4412a5af5356d24d
> > 5c6b66cf72e;hb=HEAD
> >
Looks good.

> > I wanted to also do a clean-up and update the DT support because
> > the binding documentation remains obsolete etc.
> >
Yeah, I see...

> 
> I think your previous work for DT support can cover my patch.
> Do you have a plan to update and clean-up for DT support?
> 
Same here, would be nice if the patch could be seen in upcoming kernel.

If any help is required, let us know. Byungho will help you.

Thanks,
- Kukjin
