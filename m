From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Fri, 18 Jan 2008 09:08:58 -0500
Message-ID: <1200665338.4468.23.camel@localhost>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au>
	 <1200533980.4451.100.camel@localhost>
	 <20080117021743.GA5182@gondor.apana.org.au> <478EED98.6080603@iki.fi>
	 <1200573750.4508.29.camel@localhost>
	 <20080117125016.GA9820@gondor.apana.org.au> <478F58A2.6030209@iki.fi>
	 <20080117213448.GA14716@gondor.apana.org.au>  <47904B13.9060409@iki.fi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Shoichi Sakane <sakane@tanu.org>
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:60300 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756806AbYAROJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 09:09:03 -0500
Received: by py-out-1112.google.com with SMTP id u52so1548112pyb.10
        for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 06:09:02 -0800 (PST)
In-Reply-To: <47904B13.9060409@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-18-01 at 08:45 +0200, Timo Ter=E4s wrote:

> I'll run my patched kernel=20
> and try to get ipsec-tools fixed to use netlink...
> eventually.

If you are going to mod racoon to use netlink then thats without a doub=
t
the _best_ solution (linux distros dilema i had essentially disappears)=
=2E

I would suggest as looking at racoon2 since the same KAME toolsmiths ar=
e
involved (Soichi Sakane CCed) and you can kill two birds with one stone=
=2E
=20
In any case Timo - thanks again for your efforts.

cheers,
jamal

