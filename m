From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: A new 40G Network driver ready to submit to the kernel tree
Date: Thu, 06 Oct 2011 22:08:35 -0700
Message-ID: <4E8E8953.4000003@gmail.com>
References: <4E8CE4A0.4060202@oracle.com> <20111006110056.GB27447@electric-eye.fr.zoreil.com> <4E8E8278.90601@oracle.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig62C7F650F1B4126BDA7D30EA"
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	asweisun@qq.com
To: Joyce Yu - System Software <joyce.yu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21708 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249Ab1JGFIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 01:08:36 -0400
In-Reply-To: <4E8E8278.90601@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig62C7F650F1B4126BDA7D30EA
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/06/2011 09:39 PM, Joyce Yu - System Software wrote:
>
>> It is a bit old. It could be better to rebase it against David Miller'=
s
>> net-next tree as the drivers/net/ ethernet device tree has undergone
>> some changes.
>>
>> The net-next tree is currently available at:
>>
>> git://github.com/davem330/net-next.git
>>
>>  =20
> I ported the driver to the net-next tree.
>>
>> The remarks from 04/11 are still relevant but it will be a good start.=

>>
>> Did it went through internal reviewing by some usual Linux folks at
>> oracle (hint, hint) ?
>>
>>  =20
> Yes.
>
> What is the next step?=20

Submit the patches to netdev for review/acceptance.


--------------enig62C7F650F1B4126BDA7D30EA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJOjolTAAoJEOVv75VaS+3ODrkQAJ4rvjujnqGNbVRSCT2ln91a
/2UEmVoZbLZp5vKQlv0HJXE102qJKB/iKveYdUDqQDKOyg7+7kxoG//lpsbh9NJ8
7G1ZlYi8OA0oIuZnUiQrzrjxHyyITWqi5PAE2mfh1FOZ5mNnGOYX8+oGedal6qmi
JfVcI9/6iRYUbMfMX29oGK0C29rQYFGQATIiIzgPJAqV05WY6Rihl+2fDtCNK+x8
cHj4F/96t3VwnjmDf23P/pUyYJW/jz7eO0dUm64MyfOmebuPWXkDM53rBEF4YPZE
FiqO0dcHtuIrqnLoa8ZIlsxYQVO0aFDGmWS/KPHl7OrB5TFUCqz0APIucvuQQWdK
SRL3AGuLArdb3v7lLtj1xBsHdA615NPCqSvmtxikt3oyX3G5xPb1MSyn5wvZwr+0
SQR1mglsnKbfnVtr2/RA5v6StCwE1JbzPQWVjoOmNHxoBAFaHYywhXwdKz2ffkpq
J6ya2muY21zqB2gWhnaBGEAhpFvkGlWt1FQuK5BtecTllmomQIoNZyxbnnReQY+l
sz/WCPgG8uTS3Vm7MSRGX6ZX5r6j7AWV+jgcLFxzzQG00YRFXFVUiT7YCwz9u+sY
6Zi1HUQnBbGizg3Y2yzZWAkhWy5OFopghxuUFAyg3tZRgOdEc97cuiu5Kjkf/Vj5
XEx95CkZHnMIDypx1MHa
=1ZDn
-----END PGP SIGNATURE-----

--------------enig62C7F650F1B4126BDA7D30EA--
