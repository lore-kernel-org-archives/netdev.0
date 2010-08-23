From: David Miller <davem@davemloft.net>
Subject: Re: [patch 00/20] ibmveth update
Date: Sun, 22 Aug 2010 18:57:22 -0700 (PDT)
Message-ID: <20100822.185722.232757433.davem@davemloft.net>
References: <20100823000930.546065833@samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53498
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751809Ab0HWB5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 21:57:05 -0400
In-Reply-To: <20100823000930.546065833@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Mon, 23 Aug 2010 10:09:30 +1000

> Here are a number of patches for the IBM Power virtual ethernet driver.
> Patches 1-9 contain the significant changes, and patches 10-20 are style
> and formatting changes to bring it more into line with Linux coding
> standards.

What about the patches posted by Robert Jennings the other week that
enable ipv6 checksum support et al.?

http://patchwork.ozlabs.org/patch/62054/
http://patchwork.ozlabs.org/patch/62055/
http://patchwork.ozlabs.org/patch/62056/

Might I suggest that we have a central person who gathers and
submits all of the ibmveth driver changes to me?  That way I
don't have to ask questions like this.

There is also no entry for this driver in MAINTAINERS, which I
also would like to see fixed quickly. :-)

Thanks.
