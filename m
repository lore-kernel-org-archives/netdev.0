From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [V2] Add non-Virtex5 support for LL TEMAC driver
Date: Mon, 05 Apr 2010 12:16:47 -0700 (PDT)
Message-ID: <20100405.121647.91426186.davem@davemloft.net>
References: <bda26c8d-00b2-411d-b4b7-ad6954b9049e@SG2EHSMHS005.ehs.local>
	<fa686aa41003171302v46738069pae51061ba83d0818@mail.gmail.com>
	<q2xfa686aa41004051110hc960e9a0sd1d5e61f7e2a5412@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	michal.simek@petalogix.com, jtyner@cs.ucr.edu, john.linn@xilinx.com
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39339
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755872Ab0DETQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 15:16:45 -0400
In-Reply-To: <q2xfa686aa41004051110hc960e9a0sd1d5e61f7e2a5412@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>
Date: Mon, 5 Apr 2010 12:10:51 -0600

> David, are you going to pick up this patch, or would you like me to?

The submitter, when asked, stated that he couldn't even get
the driver to build on microblaze against mainline.

So I marked the patch "changed requested" because being able
to build is... you know... sort of a requirement for integration.
