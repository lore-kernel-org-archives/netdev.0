From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] [V2] net: add Xilinx emac lite device driver
Date: Thu, 20 Aug 2009 03:32:32 -0600
Message-ID: <20090820093235.6009BD7804E@mail8-dub.bigfish.com>
References: <20090819122920.37EE21728051@mail110-dub.bigfish.com><20090820.022536.264747725.davem@davemloft.net><4A8D1750.4000804@petalogix.com> <20090820.023047.86718643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<jgarzik@pobox.com>, <grant.likely@secretlab.ca>,
	<jwboyer@linux.vnet.ibm.com>, <john.williams@petalogix.com>,
	"Sadanand Mutyala" <sadanan@xilinx.com>
To: "David Miller" <davem@davemloft.net>, <michal.simek@petalogix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-dub.frontbridge.com ([213.199.154.16]:62780 "EHLO
	IE1EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225AbZHTJcf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 05:32:35 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <20090820.023047.86718643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, August 20, 2009 10:31 AM
> To: michal.simek@petalogix.com
> Cc: John Linn; netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
jgarzik@pobox.com;
> grant.likely@secretlab.ca; jwboyer@linux.vnet.ibm.com;
john.williams@petalogix.com; Sadanand Mutyala
> Subject: Re: [PATCH] [V2] net: add Xilinx emac lite device driver
> 
> From: Michal Simek <michal.simek@petalogix.com>
> Date: Thu, 20 Aug 2009 11:28:48 +0200
> 
> > There were one bug with spinlock which John L fixed but not send to
> > mainling list. :-(
> > He wanted to create new v3 version. :-(.
> > When he wake up, he send you that bug fix or v3 version with it.
> 
> Send a new version, I'll revert V2 from my tree as I didn't push it
> out yet.

I'll send a V3 version very soon, thanks. 

Sorry for the hassle as I thought there would be more comments and I'd
incorporate the bug fix into those.

Appreciate your help.

-- John

This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


