From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] [V2] Add non-Virtex5 support for LL TEMAC driver
Date: Mon, 5 Apr 2010 15:28:32 -0600
Message-ID: <1952de2f-eb73-4c5f-899f-e9ee1926df2e@SG2EHSMHS007.ehs.local>
References: <bda26c8d-00b2-411d-b4b7-ad6954b9049e@SG2EHSMHS005.ehs.local><fa686aa41003171302v46738069pae51061ba83d0818@mail.gmail.com><q2xfa686aa41004051110hc960e9a0sd1d5e61f7e2a5412@mail.gmail.com> <20100405.121647.91426186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<jwboyer@linux.vnet.ibm.com>, <john.williams@petalogix.com>,
	<michal.simek@petalogix.com>, <jtyner@cs.ucr.edu>
To: "David Miller" <davem@davemloft.net>, <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe001.messaging.microsoft.com ([207.46.51.75]:21026 "EHLO
	SG2EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756407Ab0DEVds convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 17:33:48 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <20100405.121647.91426186.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, April 05, 2010 1:17 PM
> To: grant.likely@secretlab.ca
> Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
jwboyer@linux.vnet.ibm.com;
> john.williams@petalogix.com; michal.simek@petalogix.com;
jtyner@cs.ucr.edu; John Linn
> Subject: Re: [PATCH] [V2] Add non-Virtex5 support for LL TEMAC driver
> 
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Mon, 5 Apr 2010 12:10:51 -0600
> 
> > David, are you going to pick up this patch, or would you like me to?
> 
> The submitter, when asked, stated that he couldn't even get
> the driver to build on microblaze against mainline.
> 
> So I marked the patch "changed requested" because being able
> to build is... you know... sort of a requirement for integration.

Pushed out V3 of the patch, forgot to copy you David.

Thanks,
John

This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


