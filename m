From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [PATCH v2 1/7] phylib: add RGMII-ID interface mode definition
Date: Thu, 26 Apr 2007 16:49:16 -0500
Message-ID: <20070426164916.1c1506c6.kim.phillips@freescale.com>
References: <20070413012557.4fe6eceb.kim.phillips@freescale.com>
	<462E4639.3030400@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:42787 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755230AbXDZVtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 17:49:40 -0400
In-Reply-To: <462E4639.3030400@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Apr 2007 14:02:33 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Kim Phillips wrote:
> > ---
> > this 7 part series supercedes previous 2-set ucc_geth series submitted 10 apr 2007.
> > please consider for 2.6.22
> > 
> >  include/linux/phy.h |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> applied 1-7
> 
> 
Thanks Jeff.

There are another 3 that I excluded from the series since they were
mostly independent PHY driver changes, but they are required for proper
operation for boards using ucc_geth:

this one sent 10 apr 2007:

[PATCH] Add support for the Davicom DM9161A PHY
 - http://marc.info/?l=linux-netdev&m=117624199831581&w=2

plus these two submitted 13 apr 2007:

[PATCH v2] phylib: add the ICPlus IP175C PHY driver 
 - http://marc.info/?l=linux-netdev&m=117648832616294&w=2

[PATCH v2] phylib: enable RGMII-ID on the Marvell m88e1111 PHY
 - http://marc.info/?l=linux-netdev&m=117648831716153&w=2

Thanks,

Kim
