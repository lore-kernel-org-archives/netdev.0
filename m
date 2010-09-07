From: David Miller <davem@davemloft.net>
Subject: Re: [patch 00/21] ibmveth updates
Date: Mon, 06 Sep 2010 18:22:48 -0700 (PDT)
Message-ID: <20100906.182248.242136564.davem@davemloft.net>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com, anton@samba.org
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44211
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752968Ab0IGBWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:22:30 -0400
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santiago Leon <santil@linux.vnet.ibm.com>
Date: Fri, 03 Sep 2010 23:27:58 -0500

> Here are a number of patches for the IBM Power virtual ethernet driver. They
> include Anton's patches as well as Robert's patches.  Patches 1-10 contain
> the significant changes, and patches 11-21 are style and formatting changes
> to bring it more into line with Linux coding standards.

All applied, but:

1) You edited patch #6 by hand corrupting it, which made it not even
   show up in patchwork.  I fixed this up, but please don't do this
   again without double-checking your work as this makes a lot
   of extra time wasted on my part.

2) Please follow-up with Eric Dumazet's feedback on patch #3

Thanks.
