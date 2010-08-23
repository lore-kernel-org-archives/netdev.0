From: Anton Blanchard <anton@samba.org>
Subject: Re: [patch 00/20] ibmveth update
Date: Mon, 23 Aug 2010 12:07:13 +1000
Message-ID: <20100823020713.GA8095@kryten>
References: <20100823000930.546065833@samba.org>
 <20100822.185722.232757433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51449 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290Ab0HWCLL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 22:11:11 -0400
Content-Disposition: inline
In-Reply-To: <20100822.185722.232757433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
Hi Dave,

> What about the patches posted by Robert Jennings the other week that
> enable ipv6 checksum support et al.?
> 
> http://patchwork.ozlabs.org/patch/62054/
> http://patchwork.ozlabs.org/patch/62055/
> http://patchwork.ozlabs.org/patch/62056/
> 
> Might I suggest that we have a central person who gathers and
> submits all of the ibmveth driver changes to me?  That way I
> don't have to ask questions like this.

I'll ask the ibmveth maintainter (Santi) to roll up Robert and my patches for
submission.

> There is also no entry for this driver in MAINTAINERS, which I
> also would like to see fixed quickly. :-)

Agreed, my last patch fixes that very issue :)

Anton
