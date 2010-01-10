From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 14837] New: gretap does not fragment IP
	packets
Date: Mon, 11 Jan 2010 08:59:44 +1100
Message-ID: <20100110215944.GA11599@gondor.apana.org.au>
References: <bug-14837-10286@http.bugzilla.kernel.org/> <20091218153209.45042a58.akpm@linux-foundation.org> <1261227303.11973.2.camel@bigi> <4B2ECCAB.8010702@free.fr> <1261422543.8201.6.camel@bigi> <4B45EFF3.50006@free.fr> <1263139437.11273.13.camel@bigi> <4B4A11DC.9070706@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: Benoit PAPILLAULT <benoit.papillault@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51878 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753834Ab0AJWAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 17:00:00 -0500
Content-Disposition: inline
In-Reply-To: <4B4A11DC.9070706@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 10, 2010 at 06:43:56PM +0100, Benoit PAPILLAULT wrote:
>
> I know people can be busy, I am just trying to push things forward.  
> Original bug is there :
> http://bugzilla.kernel.org/show_bug.cgi?id=14837
>
> Patch is available here :
> http://bugzilla.kernel.org/attachment.cgi?id=24332
>
> This patch fixes my issue since either packets get fragmented or an ICMP  
> error packet is sent back to the sender.

I was actually working on this back in November before getting
side-tracked by travelling.

I'll look into this again.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
