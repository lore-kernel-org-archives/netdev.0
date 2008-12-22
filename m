From: "Divy Le Ray" <divy@chelsio.com>
Subject: RE: [PATCH v3 2.6.29] cxgb3 - manage private iSCSI IP address
Date: Sun, 21 Dec 2008 18:32:18 -0800
Message-ID: <8A71B368A89016469F72CD08050AD334040AA4AA@maui.asicdesigners.com>
References: <200812190243.mBJ2hPZY008757@localhost.localdomain> <20081218.225632.113687804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<michaelc@cs.wisc.edu>, <James.Bottomley@HansenPartnership.com>,
	"Steve Wise" <swise@opengridcomputing.com>
To: "David Miller" <davem@davemloft.net>,
	"Karen Xie" <kxie@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:16506 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbYLVCd6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 21:33:58 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > [PATCH v3 2.6.29] cxgb3 - manage private iSCSI IP address
> >
> > The accelerated iSCSI traffic could use a private IP address unknown
> to the OS:
> > - The IP address is required in both drivers to manage ARP requests
> and connection set up.
> > - Added an control call to retrieve the ip address.
> > - Reply to ARP requests dedicated to the private IP address.
> >
> > Signed-off-by: Divy Le Ray <divy@chelsio.com>
> > Signed-off-by: Karen Xie <kxie@chelsio.com>
> 
> Patch applied, thank you.

Hi Dave,

I don't see the patch committed in net-next-2.6. Did it go in another
branch?

Cheers,
Divy
