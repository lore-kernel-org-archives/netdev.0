From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Convert timers to use timer_setup()
Date: Mon, 9 Oct 2017 20:10:50 +0200
Message-ID: <1de2e034-debc-d356-2ea9-e5eecb15f397@pengutronix.de>
References: <20171005005126.GA23416@beast>
 <04d30a39-3e88-e46b-ad94-686da16e571e@pengutronix.de>
 <CAGXu5jKcQ0ez7dEma5fJv3DjWABAoEm+9P_G6aMcdBv6MHnsdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="D47cmVrcFt9L7S0u0kpXGn92epK8Efxx0"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Oliver Hartkopp <socketcan@hartkopp.net>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jKcQ0ez7dEma5fJv3DjWABAoEm+9P_G6aMcdBv6MHnsdQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--D47cmVrcFt9L7S0u0kpXGn92epK8Efxx0
Content-Type: multipart/mixed; boundary="3OCJTdNND5trGJVb54wJfpKatFEDDDBm8";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
 Oliver Hartkopp <socketcan@hartkopp.net>,
 "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
 Network Development <netdev@vger.kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>
Message-ID: <1de2e034-debc-d356-2ea9-e5eecb15f397@pengutronix.de>
Subject: Re: [PATCH] net: can: Convert timers to use timer_setup()
References: <20171005005126.GA23416@beast>
 <04d30a39-3e88-e46b-ad94-686da16e571e@pengutronix.de>
 <CAGXu5jKcQ0ez7dEma5fJv3DjWABAoEm+9P_G6aMcdBv6MHnsdQ@mail.gmail.com>
In-Reply-To: <CAGXu5jKcQ0ez7dEma5fJv3DjWABAoEm+9P_G6aMcdBv6MHnsdQ@mail.gmail.com>

--3OCJTdNND5trGJVb54wJfpKatFEDDDBm8
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: quoted-printable

On 10/09/2017 08:09 PM, Kees Cook wrote:
> On Mon, Oct 9, 2017 at 10:53 AM, Marc Kleine-Budde <mkl@pengutronix.de>=
 wrote:
>> On 10/05/2017 02:51 AM, Kees Cook wrote:
>>> In preparation for unconditionally passing the struct timer_list poin=
ter to
>>> all timer callbacks, switch to using the new timer_setup() and from_t=
imer()
>>> to pass the timer pointer explicitly.
>>>
>>> Cc: Oliver Hartkopp <socketcan@hartkopp.net>
>>> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
>>> Cc: "David S. Miller" <davem@davemloft.net>
>>> Cc: linux-can@vger.kernel.org
>>> Cc: netdev@vger.kernel.org
>>> Cc: Thomas Gleixner <tglx@linutronix.de>
>>> Signed-off-by: Kees Cook <keescook@chromium.org>
>>> ---
>>> This requires commit 686fef928bba ("timer: Prepare to change timer
>>> callback argument type") in v4.14-rc3, but should be otherwise
>>> stand-alone.
>>
>> Are you taking the patch or should I apply it?
>>
>> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
>=20
> If you have -rc3 in your tree, please take it. If you want the timers
> tree to carry it instead, we can do that too.

I think it will hit mainline faster via your tree, as it will go via
net-next. You've my acked-by.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--3OCJTdNND5trGJVb54wJfpKatFEDDDBm8--

--D47cmVrcFt9L7S0u0kpXGn92epK8Efxx0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlnbu6oACgkQHv7KIOw4
HPZG7ggAligHi21MQu+5erns0N1xXD/dp642K2tVhD56VtpSpLctbVvHNQU9rxpj
WlcU0LTBcjjFSXCTSWHFEkCeT+ggstuQl3TOLMBfAuiqMcUxPp+6m8NNm4eAVFGq
W38c+czLrBj0o2TDiVh++liH+Eqv0RxIUptdlAUiJg3rMSDHB4GbMxqV0/viriki
xSDQT/ch+0IoC18N72lKjkFjYWJMQgwjdK6eXSPRhd4n9Xi3MrlziuFcd0ax1vge
dJxmeBCFBa14C+ahOzPMu5xBibTbqSmtJxNAnrwNis5Y8/vjJPE+aIljXXSmZ7+2
SVTq3SRa/za1yfHgDWtZQzEBaVbjGg==
=KGSh
-----END PGP SIGNATURE-----

--D47cmVrcFt9L7S0u0kpXGn92epK8Efxx0--
