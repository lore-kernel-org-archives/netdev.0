From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Tons of "BUG: dst overflow ..." messages
Date: Wed, 29 Sep 2004 15:36:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415B0EB5.3010809@pobox.com>
References: <415A3635.4070000@pobox.com>	<20040928214055.609f7715.davem@davemloft.net>	<415A40D0.7040403@pobox.com> <20040929.143216.55773467.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: jgarzik@pobox.com, davem@davemloft.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040929.143216.55773467.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <415A40D0.7040403@pobox.com> (at Wed, 29 Sep 2004 00:57:52 -=
0400), Jeff Garzik <jgarzik@pobox.com> says:
>=20
>=20
>>David S. Miller wrote:
>>
>>>On Wed, 29 Sep 2004 00:12:37 -0400
>>>Jeff Garzik <jgarzik@pobox.com> wrote:
>>>
>>>
>>>
>>>>BUG: dst underflow 0: cf5dd180 at f8c0be5d
>=20
> :
>=20
>>>Can you match up the 0xf8xxxxxx addresses to spots
>>>in your System.map?  Thanks.
>=20
> :
>=20
>>ipv6 232192 38 - Live 0xf8c01000
>>		       ^^^^  appears to be this
>=20
>=20
> Hmm, I haven't met this (during TAHI test against latest tree).
> Would you try latest bk tree?

I will try soon...  it's my fileserver and router, so does not get=20
upgraded very often.


> Plus, if you know how to reproduce this, tell me.

Sorry, I do not know :(

Regards,

	Jeff
