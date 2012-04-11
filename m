From: Toralf =?utf-8?q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Subject: Re: Fwd: build issue #1 for v3.4-rc2-23-g923e9a1 :
Date: Wed, 11 Apr 2012 15:12:19 +0200
Message-ID: <201204111512.19554.toralf.foerster@gmx.de>
References: <201204111004.25018.toralf.foerster@gmx.de> <1334132071.2481.13.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:46325 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1760166Ab2DKNM1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 09:12:27 -0400
In-Reply-To: <1334132071.2481.13.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jeff Kirsher wrote at 10:14:31
> Well I can see your config is not up to date for one thing.  First I
> would try `make defconfig` OR run `make menuconfig` first.  Your comp=
ile
> complains of a 3com driver which your .config has not enabled (probab=
ly
> because it is an old .config from a kernel previous to 3.2).
Right - my fault, sry.

--=20
MfG/Sincerely
Toralf F=C3=B6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
