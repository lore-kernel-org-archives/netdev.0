From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: linux-2.6.9 eepro100 warning
Date: Thu, 28 Oct 2004 00:36:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4180773F.3060307@pobox.com>
References: <200410232313.AA00003@prism.kumin.ne.jp>	<417C9A4E.3030909@pobox.com> <20041025.152749.00307602.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: jgarzik@pobox.com, nakasima@kumin.ne.jp, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041025.152749.00307602.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <417C9A4E.3030909@pobox.com> (at Mon, 25 Oct 2004 02:16:46 -=
0400), Jeff Garzik <jgarzik@pobox.com> says:
>=20
>=20
>>Note that eepro100 driver will be deleted soon.
>=20
>=20
> I'm afraid that e100 does not work well on some systems (e.g. my ThinkP=
ad
> T30 on 2.4.x) while eepro100 does.
> (I also know there're systems which does not work well
> with eepro100 but e100.)
>=20
> Has all of such kind of issues been solved?


My overall position is, -almost all- the issues have been solved in=20
e100, so this should flush the last remaining ones out of the woodwork.=20
  Otherwise nobody will ever notice much less test e100 on these various=20
edge cases.

	Jeff
