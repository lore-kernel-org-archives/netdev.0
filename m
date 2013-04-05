From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] ISDN: isdnloop: C grammar issue, '}' miss match
 'if' and 'switch' statement.
Date: Fri, 05 Apr 2013 14:09:54 +0800
Message-ID: <515E6AB2.1010803@asianux.com>
References: <1364999477.13853.21.camel@edumazet-glaptop> <CA+55aFw+Efs+um15_V6t-9rXd-U1VJS9p+_6E-m5jr87h-BPVg@mail.gmail.com> <515D3A09.7040202@asianux.com> <20130404.140956.2233513394092413594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, eric.dumazet@gmail.com,
	mkubecek@suse.cz, fengguang.wu@intel.com, isdn@linux-pingi.de,
	netdev@vger.kernel.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:61351 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002Ab3DEGKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 02:10:25 -0400
In-Reply-To: <20130404.140956.2233513394092413594.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=C4=EA04=D4=C205=C8=D5 02:09, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Thu, 04 Apr 2013 16:30:01 +0800
>=20
>>> >> Of course, nobody sane actually cares about ISDN any more, so I =
think
>>> >> this is all pretty academic. I think even Germany (where ISDN *u=
sed*
>>> >> to be very common due to telephone monopolies and odd rules) no =
longer
>>> >> uses it. I can't imagine that anybody else does either.
>>> >>=20
>> >=20
>> >   can we delete it ?
> I think the point is no that we can delete it, but rather that we
> should concentrate our efforts on code that more people use rather
> than trying to clean up antiquated code with very few users.
>=20
>=20

  ok, we should respect the opinions of the related maintainers.

  although for me:
    I still suggest to apply the Linus' patch, if we do not delete ISDN=
=2E

  next, I will not be still focus on ISDN.


BTW:
  the reasons why I am interested in ISDN are:
    a: I am trying to improve finding issues ability, by reading code.
    b: quite a few of ISDN codes seem quite surprising or strange.
    c: when I am reading, I make several mistakes and misunderstanding.

  the above 3 are the whole reasons why I am interested in ISDN.

  thanks.

  :-)

--=20
Chen Gang

Asianux Corporation
