From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Sun, 27 Apr 2008 01:06:52 -0700 (PDT)
Message-ID: <20080427.010652.219927052.davem@davemloft.net>
References: <20080426.123359.14563419.yoshfuji@linux-ipv6.org>
	<OF6237355B.2CBF6C7D-ON88257437.007F7B3D-88257437.00837003@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40070
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752169AbYD0IGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 04:06:53 -0400
In-Reply-To: <OF6237355B.2CBF6C7D-ON88257437.007F7B3D-88257437.00837003@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Sat, 26 Apr 2008 17:55:44 -0600

> Add support on 64-bit kernels for seting 32-bit compatible
> MCAST* socket options.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Ok, this is a lot cleaner than I imagined it might be :-)

Patch applied, thanks everyone!

After this sits for a bit, I'll queue it up to -stable
as well.

Thanks again!
