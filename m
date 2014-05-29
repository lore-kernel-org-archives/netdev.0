From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: Fw: [PATCH net,stable 0/7] qmi_wwan: adding a few new devices
Date: Thu, 29 May 2014 11:05:35 +0200
Message-ID: <5386F85F.8040203@suse.cz>
References: <20140528.130419.1111511028177579041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	stable <stable@vger.kernel.org>
To: bjorn@mork.no
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140528.130419.1111511028177579041.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/28/2014 07:04 PM, David Miller wrote:
> Just FYI when doing your 3.12 stuff...
>=20
>=20
> Re: [PATCH net,stable 0/7] qmi_wwan: adding a few new devices.eml
>=20
> P=C5=99edm=C4=9Bt:
> Re: [PATCH net,stable 0/7] qmi_wwan: adding a few new devices
> Od:
> Bj=C3=B8rn Mork <bjorn@mork.no>
> Datum:
> 26.4.2014 19:18
>=20
> Komu:
> netdev@vger.kernel.org
> Kopie:
> linux-usb@vger.kernel.org
>=20
>=20
> Bj=C3=B8rn Mork <bjorn@mork.no> writes:
>=20
>> > These new device ID patches should also go to all maintained stabl=
e kernels
>> > where they apply. I believe that should be stable-3.10 and newer.
> At least if the following mainline commits are cherry-picked first,
> bringing the device id list up-to-date with v3.14:
=2E..
> For stable-3.12.y:
>=20
> 905468fa4d54 net: qmi_wwan: add Telit LE920 newer firmware support
>   [requires context fixup]
> 7653aabfbdc7 net: qmi_wwan: add ZTE MF667
> 9b2b6a2d669c net: qmi_wwan: add support for Cinterion PXS8 and PHS8

Thanks, now queued up for 3.12.

--=20
js
suse labs
