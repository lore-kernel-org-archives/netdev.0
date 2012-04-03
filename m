From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Wed, 4 Apr 2012 00:31:53 +0200
Message-ID: <4F7B7A59.2090904@googlemail.com>
References: <4F75CA89.4010709@googlemail.com> <4F75D2A5.7060407@googlemail.com> <20120403.180302.342779808900865443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120403.180302.342779808900865443.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller schrieb:
[snip - my patch description]
>=20
> I'm not applying this until a powerpc person tests it.
>=20

As Benjamin already said, Matt is having a look, so i expected nothing =
else.

> Also, we have an ARM JIT in the tree which probably needs to
> be fixed similarly.
>=20

???
Oh, in which tree is it?
I was working against net-next.

Greetings
	Jan


--=20
=CB=99q=C9=90=C9=A5 =CA=87=C9=9Fn=C9=90=CA=9E=C7=9D=C6=83 =CA=8E=C9=90q=
=C7=9D =C4=B1=C7=9Dq =C9=B9n=CA=87=C9=90=CA=87s=C9=90=CA=87 =C7=9Du=C4=B1=
=C7=9D =C9=B9=C4=B1=C9=AF =C9=A5=C9=94=C4=B1 s=C9=90p l=C9=90=C9=AF =C7=
=9D=CA=87z=CA=87=C7=9Dl s=C9=90p =CA=87s=C4=B1 s=C9=90p=20
'=CA=87=C9=AF=C9=AF=C9=90p=C9=B9=C7=9D=CA=8C
