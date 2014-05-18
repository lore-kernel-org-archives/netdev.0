From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCHv4 0/5] Add DT support for fixed PHYs
Date: Sun, 18 May 2014 19:46:28 +0200
Message-ID: <20140518194628.0d0c308d@free-electrons.com>
References: <1400249647-4643-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20140516.172009.632611701865367987.davem@davemloft.net>
	<20140518121854.3b4a17fa@free-electrons.com>
	<CAGVrzcYN1-0zM0pVSFZkD5HVAwq6rXEQOBN29x+vBn9hpbmOcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:47109 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751506AbaERRqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 13:46:32 -0400
In-Reply-To: <CAGVrzcYN1-0zM0pVSFZkD5HVAwq6rXEQOBN29x+vBn9hpbmOcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian Fainelli,

On Sun, 18 May 2014 10:21:10 -0700, Florian Fainelli wrote:

> > On Fri, 16 May 2014 17:20:09 -0400 (EDT), David Miller wrote:
> >> From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> >> Date: Fri, 16 May 2014 16:14:02 +0200
> >>
> >> > Here is a fourth version of the patch set that adds a Device Tree
> >> > binding and the related code to support fixed PHYs. I'm hoping to get
> >> > this merged in 3.16.
> >>
> >> Series applied, thanks Thomas.
> >
> > Thanks! Did you also pull PATCH 5/5, which changes the Armada XP Matrix
> > Device Tree file?
> 
> It has been applied:
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=84f6e11f21d40025ae9b0ebbf1c9b3be91ea8e1a

I think it should have been routed through the mvebu tree, or at least
get the hack of the mvebu maintainers. That being said, I don't think
we have other patches for armada-xp-matrix.dts in this cycle, so maybe
having this patch go through David's tree will be OK. I'll let Jason
Cooper (Cc'ed) answer on this.

Thanks,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
