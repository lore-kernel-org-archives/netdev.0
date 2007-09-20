From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH - net-2.6.24 0/2] Introduce and use print_ip and	print_ipv6
Date: Thu, 20 Sep 2007 20:46:31 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0709202044090.7669@kivilampi-30.cs.helsinki.fi>
References: <1190271211.26101.91.camel@localhost>
 <20070920075532.b20fad42.randy.dunlap@oracle.com> <1190301928.26101.102.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48363 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbXITRqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 13:46:33 -0400
In-Reply-To: <1190301928.26101.102.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Sep 2007, Joe Perches wrote:

> On Thu, 2007-09-20 at 07:55 -0700, Randy Dunlap wrote:
> > How large are the patches if you posted them for review instead
> > of just referencing gits for them?  (which cuts down on review
> > possibilities)
> 
> The v4 is ~130kb, the v6 ~35kb.
>
> There is a gitweb available at:
> 
> print_ip:
> http://repo.or.cz/w/linux-2.6/trivial-mods.git?a=shortlog;h=print_ipv4
> commit diff:
> http://repo.or.cz/w/linux-2.6/trivial-mods.git?a=commitdiff;h=1e3a30d5d8b49b3accca07cc84ecf6d977cacdd5
> 
> print_ipv6:
> http://repo.or.cz/w/linux-2.6/trivial-mods.git?a=shortlog;h=print_ipv6
> commit diff:
> http://repo.or.cz/w/linux-2.6/trivial-mods.git?a=commitdiff;h=e96b794a57a164db84379e2baf5fe2622a5ae3bf

...Alternatively you could split it up a bit and send those smaller 
chunks for reviewing purposes only (even though it would be combined
to a single big patch in the end).

-- 
 i.
