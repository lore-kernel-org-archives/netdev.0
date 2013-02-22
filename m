From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Fri, 22 Feb 2013 12:25:01 +0000 (UTC)
Message-ID: <loom.20130222T132206-265@post.gmane.org>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com> <loom.20130204T174808-896@post.gmane.org> <CAHrpEqSXhEBQpnR60mjP67gbVWNemfa3tTuoDTKipej_6QQ62g@mail.gmail.com> <loom.20130205T111507-687@post.gmane.org> <CAHrpEqTsUjWjxY3_C4kGL_S0pgpYawgBaSip3DEnZd3CY1hn0A@mail.gmail.com> <51125F28.4000409@intel.com> <CAHrpEqR9u5t8fZOYRq4k_vTsEORVsNwa2C_rLaxesmusY5e9-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:38307 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754860Ab3BVMZW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2013 07:25:22 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1U8rh5-0000zs-Ns
	for netdev@vger.kernel.org; Fri, 22 Feb 2013 13:25:39 +0100
Received: from jimbax.plus.com ([81.174.248.107])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 13:25:39 +0100
Received: from jim_baxter by jimbax.plus.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 13:25:39 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > On 2/6/2013 1:50 AM, Frank Li wrote:
> >>
> >>
> >> It is not easy to fix. Need put tx to NAPI poll function.
> >> I will work on that after China New year holiday



Hi Frank,

Have you had time to have a look at this issues again?

Jim
