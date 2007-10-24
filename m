From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH 0/3][XFRM]: Support packet processing error
	statistics.
Date: Wed, 24 Oct 2007 08:25:02 -0400
Message-ID: <1193228703.4442.14.camel@localhost>
References: <11930334662094-git-send-email-nakam@linux-ipv6.org>
	 <1193056091.4422.33.camel@localhost>
	 <200710231608.34661.nakam@linux-ipv6.org>
	 <20071024.125925.86627480.yoshfuji@linux-ipv6.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nakam@linux-ipv6.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:4311 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757985AbXJXMZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 08:25:13 -0400
Received: by wx-out-0506.google.com with SMTP id h31so186885wxd
        for <netdev@vger.kernel.org>; Wed, 24 Oct 2007 05:25:12 -0700 (PDT)
In-Reply-To: <20071024.125925.86627480.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-24-10 at 12:59 +0900, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E wrote:
> In article <200710231608.34661.nakam@linux-ipv6.org> (at Tue, 23 Oct =
2007 16:08:34 +0900), Masahide NAKAMURA <nakam@linux-ipv6.org> says:
>=20

> > Now we have the following candidates:
> >=20
> > (1) my patch		XFRM_MIB_INHDRERROR
> > (2) some extender	XFRM_XXX_INHDRERROR	(XXX is requested)
> > (3) not-mib extender	XFRM_NOTMIB_INHDRERROR
> > (4) no extender		XFRM_INHDRERROR
> > (5) merge linux-mib	LINUX_MIB_XFRMINHDRERROR
> >=20
> > Comments?
>=20
> I would support (5) or (1).

#5 it is then.

cheers,
jamal

