From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH]:[XFRM] BEET mode
Date: Thu, 14 Sep 2006 09:09:07 -0700
Message-ID: <20060914090907.cb8b10e9.rdunlap@xenotime.net>
References: <1158164779.4508312bab9c2@webmail.hiit.fi>
	<20060913201423.06990b98.rdunlap@xenotime.net>
	<Pine.SOL.4.64.0609141316420.361@kekkonen.cs.hut.fi>
	<20060914083959.60538a79.rdunlap@xenotime.net>
	<1158249146.45097abad4371@webmail.hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, netdev@vger.kernel.org,
	davem@davemloft.net, Herbert Xu <herbert@gondor.apana.org.au>,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:60085 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1750934AbWINQH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 12:07:58 -0400
Received: from midway.site ([71.117.233.155]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 14 Sep 2006 09:07:53 -0700
To: Diego Beltrami <Diego.Beltrami@hiit.fi>
In-Reply-To: <1158249146.45097abad4371@webmail.hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Sep 2006 18:52:26 +0300 Diego Beltrami wrote:

> 
> > I suppose that this applies to Dave's netdev git tree?
> > That would explain why I get lots of patch errors when I try
> > to apply it to 2.6.18-rc7...
> 
> Actually we made the patch against linux/kernel/git/acme/net-2.6.19.git
> 
> is that the wrong branch?

I can answer, but it won't be authoritative, so someone else
should also answer.

I would expect patches to be made against DaveM's
2.6.19 git or 2.6.x git trees:

http://www.kernel.org/git/?p=linux/kernel/git/davem/net-2.6.19.git;a=summary
http://www.kernel.org/git/?p=linux/kernel/git/davem/net-2.6.git;a=summary

although the acme tree may be tracking DaveM's tree(s) closely.

---
~Randy
