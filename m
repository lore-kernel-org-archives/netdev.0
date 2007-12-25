From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: [PATCH] [IPROUTE2] IPT action compatibility with iptables 1.4.0
Date: Tue, 25 Dec 2007 17:50:23 +0200
Message-ID: <20071225154312.M15617@visp.net.lb>
References: <1198515305.4427.12.camel@localhost> <20071224094807.060e604f@deepthought> <1198519052.4427.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>
To: hadi@cyberus.ca,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:43675 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbXLYPuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 10:50:51 -0500
In-Reply-To: <1198519052.4427.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will try to be more careful on patches formatting. I am newbie to this.
And thanks for all responding on christmas :-) Usually all people N/A at this
time.

It seems 2.6.24-rc6 + iptables 1.4.0 + iproute2-git working fine now.



On Mon, 24 Dec 2007 12:57:32 -0500, jamal wrote
> On Mon, 2007-24-12 at 09:48 -0800, Stephen Hemminger wrote:
> > On Mon, 24 Dec 2007 11:55:05 -0500
> 
> > Is this backwards compatible with older kernels?
> 
> Yes. 
> Denys change adds forward compat (although iptables in 1.4 is not fully
> backward compatible).
> 
> cheers,
> jamal
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

