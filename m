From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Thu, 3 Aug 2006 15:28:57 +0200
Message-ID: <200608031528.57668.netdev@axxeo.de>
References: <200608010231.58339.ak@suse.de> <20060801120003.GY8334@innerghost.net> <20060801.145705.71091996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hsantos@av.it.pt, ak@suse.de, herbert@gondor.apana.org.au,
	kazunori@miyazawa.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:979 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S932085AbWHCN3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 09:29:49 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.145705.71091996.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

David Miller wrote:
> Developer momentum means that the kernel is likely to get fixed
> whereas the userland component will more likely rot and not get
> fixed.
> 
> So in this sense resiliency does depend upon something being in
> the kernel or not.

I can only agree here. Lots of users use their own kernels instead 
of distribution kernels. Much less users divert core software from 
their distribution.

The big binary called bzImage/vmlinux whatever is a huge usability
advantage here :-)


Regards

Ingo Oeser
