From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Wed, 7 Apr 2010 07:25:37 -0600
Message-ID: <b8be47d5-5db7-4e72-a45f-94fc54b7f370@VA3EHSMHS036.ehs.local>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local><1270502993.9013.36.camel@edumazet-laptop> <20100406.195204.165441511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<grant.likely@secretlab.ca>, <jwboyer@linux.vnet.ibm.com>,
	<john.williams@petalogix.com>, <michal.simek@petalogix.com>,
	<jtyner@cs.ucr.edu>
To: "David Miller" <davem@davemloft.net>, <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:14225
	"EHLO VA3EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757908Ab0DGN0g convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Apr 2010 09:26:36 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <20100406.195204.165441511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, April 06, 2010 8:52 PM
> To: eric.dumazet@gmail.com
> Cc: John Linn; netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
grant.likely@secretlab.ca;
> jwboyer@linux.vnet.ibm.com; john.williams@petalogix.com;
michal.simek@petalogix.com; jtyner@cs.ucr.edu
> Subject: Re: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
> 
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 05 Apr 2010 23:29:53 +0200
> 
> > So, I ask, cant you use netdev_alloc_skb_ip_align() in this driver ?
> 
> Thanks to everyone for getting this patch into shape.
> 
> I applied version 4 of the patch to net-next-2.6, thanks!

Thanks David, appreciate everyone's help and patience.

This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


