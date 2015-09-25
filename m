From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: Re: [PATCH v7 02/10] ss: created formatters for json and hr
Date: Fri, 25 Sep 2015 08:01:59 +0200
Message-ID: <5604E357.9000802@gmx.net>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net>
 <20150923162650.148fe95b@urahara>
 <bc9cacb94de24857a7d9e13960bfae56@HQ1WP-EXMB11.corp.brocade.com>
 <20150924151630.28129cdb@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"edumazet@google.com" <edumazet@google.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:64860 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334AbbIYGCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 02:02:12 -0400
In-Reply-To: <20150924151630.28129cdb@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA384

On 09/25/2015 12:16 AM, Stephen Hemminger wrote:
> On Thu, 24 Sep 2015 17:43:46 +0000 Matthias Tafelmeier 
> <matthias.tafelmeier@gmx.net> wrote:
> 
>>> Maybe it is time to rewrite it in a better language ;-)
>> 
>> I did not get that. Do you mean iproute2?
> 
> I meant that the amount of formatting and string processing in ss 
> is getting to be a significant fraction of the code. Languages 
> other C provide more OO and better string handling that might help.
> But mostly it was a joke.
> 

I suspected you meant that but I was not sure since little out of
context. ;)

Well, then we should wait for another voice aimed at the complexity of
the patchset before amending and resending me the patchset.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCQAGBQJWBONXAAoJEOAWT1uK3zQ7M2UIANB3xiPOr4/hB3LVvgv4Vv1s
xMSVLbhGV2FDWSI3KaLIAov9b4ZFevM1usozAhKwHypw0pjtoZzrL6x78fgEumOz
juOnz7iQJZJ0mP3+N+CUHKT/uDX43fkDMCyrpfF7ZnsLJ77KT/WNcb1trtxkm8W7
0+YZp++qve9GELVhy5eLJHbmt36i7DTTGnby+l9SkLuz53QL0zkidmbHyYVfLgDD
kPT2AHOrvKhg4+vs3o1TdOPGUSXe5dnK+LVwRlu4f1FH1G029V4bS4Pa4MTlYzSM
Zl7j8jjk9LsmWN86SYFxAngcVu6iHP6tHqAKHbIDYCzr28B2nEYVwFqIe4PJp9Q=
=YT+J
-----END PGP SIGNATURE-----
