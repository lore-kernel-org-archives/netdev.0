From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next] liquidio: update debug console logging mechanism
Date: Tue, 15 Aug 2017 10:22:28 +0300
Message-ID: <20170815072228.GM24282@mtr-leonro.local>
References: <20170812014314.GA1012@felix-thinkpad.cavium.com>
 <20170813055549.GO24282@mtr-leonro.local>
 <CY1PR0701MB1961883A407496B03A8FD870EC8C0@CY1PR0701MB1961.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="UhXv5VeBZ/Y8lRnC"
Cc: "Manlunas, Felix" <Felix.Manlunas@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>
To: Ricardo Farrington <Ricardo.Farrington@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:41956 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753185AbdHOHWd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 03:22:33 -0400
Content-Disposition: inline
In-Reply-To: <CY1PR0701MB1961883A407496B03A8FD870EC8C0@CY1PR0701MB1961.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UhXv5VeBZ/Y8lRnC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 14, 2017 at 04:28:50PM +0000, Ricardo Farrington wrote:
> Hi Leon - the code to which this patch applies handles a data stream from our card's firmware to the host (over PCI).
> There are device-specific registers which are accessed to transfer log data from our firmware to the host.
> I don't think there is kernel code that we could use to perform this; this is not general purpose host driver logging.

I see, it is not really clear form the name "console".

Thanks

--UhXv5VeBZ/Y8lRnC
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmSoTQACgkQ5GN7iDZy
WKeE8BAAzva+CHkHIHwdDQBFSJAmNjACGm7SBjuT6UiTV3wxIlvRV12dJaOhTnMr
joR89obrMPKBSEMhDy38/+e61c2zLSWnF0SrKX8Nb23w4DF2t82ilPhuP6JuVmvC
Spq1NaWFB1A8mYOq+M1pRMrig5LyKJXiGDz84jqUocGi1vCupoECsUUixqZ0S9KI
+Nr1qI5DoCdYwP/kQcpAFsP6mWl3+Rb9/YJAfVwvQQpauRfKkpoPh6porqv7/V0b
imsqlO5qleNFD4RARfioTrQO9jqFi/UQSC51Q9yUqiONub+4E80Q8kmgsZ3BIITi
WjfI5gefHTsK7Z+gETXlYZjyff+07JN+h+1E3kabTUgepKN1hGy86U2EETNbpqxe
qooIoo1bE+g2Pi/KMWXxKrr0xRMNQD+djsfVHKXjHXerKe4kwPNzUlq11oczDzzw
1KsjAn2GTXjV+ChlN5/uS9KkrVb0/6wjfDczjuoUEzmbXKqLF4P1FOSZkxb9YkcS
5SaJFqplsNx/YOTEj8RbLTUqTBKi/bfn8Fy6UJ+17bpWUF2teMpNRDBBHtJj599W
WoYzBalO1c+dUKmbr0niqVME1EfoDU9f00F52x2gzdpDoKh9YDfyjPbN+fB0VZ4b
f5UeI5iSgDlUhuze71ccsTI+qNrJFisP9af4fPyEHnNmLUyXqSQ=
=PNAW
-----END PGP SIGNATURE-----

--UhXv5VeBZ/Y8lRnC--
