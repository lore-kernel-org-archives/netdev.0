From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [pull request][for-next 00/12] Mellanox, mlx5 IPoIB Muli Pkey
 support 2017-10-11
Date: Sat, 14 Oct 2017 17:19:34 -0400
Message-ID: <af28440c-bb1c-c47b-92dd-60bfbeaa839d@redhat.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="CerHnF4lIdbG3wGNXhWPTaS0oxBcOmmBF"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171014184827.18491-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--CerHnF4lIdbG3wGNXhWPTaS0oxBcOmmBF
Content-Type: multipart/mixed; boundary="3ELhehl2SM9xNQEdpvii5g8B8nUg1fVO2";
 protected-headers="v1"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Message-ID: <af28440c-bb1c-c47b-92dd-60bfbeaa839d-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [pull request][for-next 00/12] Mellanox, mlx5 IPoIB Muli Pkey
 support 2017-10-11
References: <20171014184827.18491-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
In-Reply-To: <20171014184827.18491-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--3ELhehl2SM9xNQEdpvii5g8B8nUg1fVO2
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 10/14/2017 2:48 PM, Saeed Mahameed wrote:
> Hi Dave and Doug,
>=20
> This series includes updates for mlx5 IPoIB offloading driver from Alex=

> and Feras to add the support for Muli Pkey in the mlx5i ipoib offloadin=
g netdev,
> to be merged into net-next and rdma-next trees.

As far as the two IPoIB patches are concerned, they're fine.

> Doug, I am sorry I couldn't base this on rc2 since the series needs and=
 conflicts
> with a fix that was submitted to rc3, so to keep things simple I based =
it on rc4,
> I hope this is ok with you..

No worries, it just means I have to submit it under another branch.  But
I'm already holding one patch series in a stand alone branch, so no big
deal.  And, actually, the IPoIB changes are so small they can simply go
through Dave's tree if you don't have any dependent code in the IPoIB
driver to submit after this but still in this devel cycle.

> Please pull and let me know if there's any problem.

Once I hear that Dave is OK with the net changes, I'm ready to pull (if
I need to).

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FD=
D


--3ELhehl2SM9xNQEdpvii5g8B8nUg1fVO2--

--CerHnF4lIdbG3wGNXhWPTaS0oxBcOmmBF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJZ4n9mAAoJELgmozMOVy/dMTkP/0VBgkrfwR835SJtZP43MTw7
UO0quTG1VVPv0eTgcxErJvTrK5YcwpAiVOLH5ZHLvmHNRO7CC/W0zhJ1e7UA06yI
DWP70LmhBJ8UDcdsjWU0Pbe99AndAcNJeHqxx2RVFBFbW0sQUVmDnwMUdsVkX2LG
nBQIzTwBoWK6UmgUnMLRlD74eIhsCB1jcceq/8zA9Mvrpha2isLgkMFMwz9uaPvF
myLChi7cJLI/lEeHzkv/6gJOkd80fX5vyNzznfZk4dAo9uaGA72WQoR2XqRmAoZ/
w1y2iHtMw/Nn6VHg/Z3KFPqsqTi06tPru9X4yyUQWEzEhv3KguOTQvnImHKQtXus
QJiFSGpk4df/zhT9JnFIBqHYBgAybLfhTHXV4DUXCZfuTO/N05GmnVdGtzWHBoHz
0QgcgdI+XWSh/1gHrXR/B5lsNJMd7TdA++S0l5QfayvFLoOaHq9BsbvQIJgmQ6n9
EUmndhwB5fztQ+NMPhpajHCZpW01SPherfdThQGCRc89UXALGC52MSRScsDojc/0
LC8g2Y80f4eo6qiIUriUBnur9vcUuJZz3KJKFHr2Dgz0BDz6vTsrXJS9B2KfxCUj
Q3809tE8k0riKFfy4O0f3b1xSdLpCkelFhrjLIBXopFIJdoxjg6ltWrDExKCDgcJ
h1npPjZLOfC4kpnu/I68
=B+xd
-----END PGP SIGNATURE-----

--CerHnF4lIdbG3wGNXhWPTaS0oxBcOmmBF--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
