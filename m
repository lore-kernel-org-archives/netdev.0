From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]: Can not set the IPV6_PKTINFO option
Date: Mon, 16 Jul 2007 23:17:01 +0900 (JST)
Message-ID: <20070716.231701.04033316.yoshfuji@linux-ipv6.org>
References: <200707161438.02572@strip-the-willow>
	<E1IAR9h-0007nr-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au, gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48076 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762836AbXGPOQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 10:16:19 -0400
In-Reply-To: <E1IAR9h-0007nr-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <E1IAR9h-0007nr-00@gondolin.me.apana.org.au> (at Mon, 16 Jul 2007 22:02:29 +0800), Herbert Xu <herbert@gondor.apana.org.au> says:

> Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > 
> > Manpage date says 1999-06-29 but in fact manpages are from up-to-date lenny/sid.
> 
> I think Yoshifuji-san's point is not that your manpages package
> is out-of-date, but that the manpage itself is out-of-date.
> That is, someone needs to send a patch to the upstream manpages
> maintainer and fix the documentation to actually describe what the
> code does.

Exactly.  The ipv6(7) manpage is one of the TODOs.
Contributions, expecially from native speakers, are really welcome.

--yoshfuji
