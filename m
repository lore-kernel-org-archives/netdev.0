From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH 0/2] cxgb4 FR_NSMR_TPTE_WR support
Date: Mon, 3 Oct 2016 10:50:06 -0400
Message-ID: <3eb216ed-4eff-596d-18a0-65668b5d285e@redhat.com>
References: <cover.1474037695.git.swise@opengridcomputing.com>
 <20160919.011633.1357649774235825501.davem@davemloft.net>
 <007f01d21280$7d1556b0$77400410$@opengridcomputing.com>
 <20160919.102920.1126387243122900012.davem@davemloft.net>
 <023401d2190b$03b00e50$0b102af0$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="3fSVSP5x9djq05j9P0IrHUw4CUGAc4I6N"
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        "'David Miller'" <davem@davemloft.net>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36896 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752409AbcJCOuN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 10:50:13 -0400
In-Reply-To: <023401d2190b$03b00e50$0b102af0$@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3fSVSP5x9djq05j9P0IrHUw4CUGAc4I6N
Content-Type: multipart/mixed; boundary="3mbF40PEtqHsw6VHq6bExxxfrq3AdUiNl";
 protected-headers="v1"
From: Doug Ledford <dledford@redhat.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
 'David Miller' <davem@davemloft.net>
Message-ID: <3eb216ed-4eff-596d-18a0-65668b5d285e@redhat.com>
Subject: Re: [PATCH 0/2] cxgb4 FR_NSMR_TPTE_WR support
References: <cover.1474037695.git.swise@opengridcomputing.com>
 <20160919.011633.1357649774235825501.davem@davemloft.net>
 <007f01d21280$7d1556b0$77400410$@opengridcomputing.com>
 <20160919.102920.1126387243122900012.davem@davemloft.net>
 <023401d2190b$03b00e50$0b102af0$@opengridcomputing.com>
In-Reply-To: <023401d2190b$03b00e50$0b102af0$@opengridcomputing.com>

--3mbF40PEtqHsw6VHq6bExxxfrq3AdUiNl
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 9/27/2016 6:03 PM, Steve Wise wrote:
>>
>>>
>>>>
>>>> From: Steve Wise <swise@opengridcomputing.com>
>>>> Date: Fri, 16 Sep 2016 07:54:55 -0700
>>>>
>>>>> This series enables a new work request to optimize small REG_MR
>>>>> operations.  This is intended for 4.9.  If everyone agrees, I sugge=
st
>>>>> Doug take both the cxgb4 and iw_cxgb4 patches through his tree.
>>>>
>>>> I'm assuming this mean that I do _not_ apply these to my tree.
>>>
>>> Yes, if you're ok with that.
>>
>> I am.
>=20
> Doug, please include this for 4.9 if it looks good to you.  Let me know=
=2E
>=20
> Thanks,
>=20
> Steve.
>=20

Applied, thanks.

--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--3mbF40PEtqHsw6VHq6bExxxfrq3AdUiNl--

--3fSVSP5x9djq05j9P0IrHUw4CUGAc4I6N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJX8nAeAAoJELgmozMOVy/dSjkQAKaf6Mk7UXNYkYPNA7rmluyA
lB1GgtrbiLKFjqEZhXmYPR4wHsnmineiAjfxyjbdLTM/dZTmTcoglRoatYb6wPzr
4n4SINlu9Be/ZYsGijwdzsHvRjz1BuVgVhxI7A7JSqdl6NCpvcMBLtI3vAwu0Jkv
HwN6XDlUaNvcZhHeJib+1/55wXIU68R8U/f+3ymlZImztFT6S5mv3p/BObniO07m
muVM7/9s81n+1yhJOXMbeXuVpk6sGo+378N/QLLGjKKTNs1FtIrko/+1PUnRXflO
UTtKAsGyHAQYz+P9WjDmk+1RWtp79PfZRp+NbcKVbkyj/Tbwi0QpA6s8xJZ4Ruf5
SP1tF0fIl8Iiej9RWQEoO+067vLYr9lo8v+qzorUhEF1fK+VDqEBNwSy91kjdpf0
MldcgjbGvUiDWOqAb4/cpLifXrroZ+Zy3M6FvRfo4EI+UBEUGG0NNiwnWz8BMVYs
YnyiEuajQaVnBsWtamVdD+5WbhmciqgJYnSLonYySIJ7S/7WTKbrYnDJdTLOuggM
sLDawV9dsmwM+Jfieso/ZGOQDWMwHWd5ylNj6xxFIcqZ4CWAeSlBkHUQZxiDvPsk
uDqY2T15y73EsEG8Yw/MsqYwjF+eZS+ApPgUWIDcV+kl0guaKggA4mOT0zsM6CWg
O0kUmuiMw5y1pA0CZaDi
=tiic
-----END PGP SIGNATURE-----

--3fSVSP5x9djq05j9P0IrHUw4CUGAc4I6N--
