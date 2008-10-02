From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] ibm_newemac: Add support for GPCS, SGMII andM88E1112
 PHY
Date: Thu, 2 Oct 2008 06:33:20 -0400
Message-ID: <20081002063320.7b2331b4@zod.rchland.ibm.com>
References: <1222929477-10329-1-git-send-email-vgallardo@amcc.com>
	<1222929920.12264.96.camel@pasglop>
	<0CA0A16855646F4FA96D25A158E299D602C81377@SDCEXCHANGE01.ad.amcc.com>
	<1222932759.12264.104.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Victor Gallardo <vgallardo@amcc.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:36967 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752127AbYJBKdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 06:33:24 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m92AXLTZ005829
	for <netdev@vger.kernel.org>; Thu, 2 Oct 2008 06:33:21 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m92AXLmX257374
	for <netdev@vger.kernel.org>; Thu, 2 Oct 2008 06:33:21 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m92AXL8D025781
	for <netdev@vger.kernel.org>; Thu, 2 Oct 2008 06:33:21 -0400
In-Reply-To: <1222932759.12264.104.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 02 Oct 2008 17:32:39 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Thu, 2008-10-02 at 00:30 -0700, Victor Gallardo wrote:
> > 
> >  
> > Yes, this based on Josh's git repository. Should I sync up with your
> > git repository or is Josh's OK.
> 
> Josh is fine.
> 
> Jeff, can we merge all those EMAC patches via the powerpc git ? need an
> ack from you I suppose ...

I already have this in my tree.  Jeff already acked it (twice now I
think).

http://git.kernel.org/?p=linux/kernel/git/jwboyer/powerpc-4xx.git;a=shortlog;h=next

josh
