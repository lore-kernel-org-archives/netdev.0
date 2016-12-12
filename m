From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V2 00/22] Broadcom RoCE Driver (bnxt_re)
Date: Mon, 12 Dec 2016 18:52:47 -0500
Message-ID: <23e26353-4317-2836-9f94-d1fc3274a770@redhat.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="c34KNfshmHK5jRdwv0P7Q4ac4v8omjXIK"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--c34KNfshmHK5jRdwv0P7Q4ac4v8omjXIK
Content-Type: multipart/mixed; boundary="O379wKSNU7mbrTrVeHLFtjBp7qXLmWIM2";
 protected-headers="v1"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <23e26353-4317-2836-9f94-d1fc3274a770-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V2 00/22] Broadcom RoCE Driver (bnxt_re)
References: <1481266096-23331-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>

--O379wKSNU7mbrTrVeHLFtjBp7qXLmWIM2
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/9/2016 1:47 AM, Selvin Xavier wrote:
> This series introduces the RoCE driver for the Broadcom
> NetXtreme-E 10/25/40/50 gigabit RoCE HCAs.=20
> This driver is dependent on the bnxt_en NIC driver and is=20
> based on the bnxt_re branch in Doug's repository. bnxt_en changes
> required for this patch series is already available in this branch.
>=20
> I am preparing a git repository with these changes as per Jason's
> comment and will share the details later today.
>=20
> v1-> v2:
>   * The license text in each file updated to reflect Dual license.
>   * Makefile and Kconfig changes are pushed to the last patch
>   * Moved bnxt_re_uverbs_abi.h to include/uapi/rdma folder
>   * Remove duplicate structure definitions from bnxt_re_hsi.h as
>     it is available in the corresponding bnxt_en header file (bnxt_hsi.=
h)
>   * Removed some unused code reported during code review.
>   * Fixed few sparse warnings
>=20
> Doug,
> Please review and consider applying this to linux-rdma repository.

There are outstanding review comments to be addressed still yet, and the
v2 patchset doesn't compile for me in 0day testing.  I'm going to bounce
this one to 4.11.


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: 0E572FDD


--O379wKSNU7mbrTrVeHLFtjBp7qXLmWIM2--

--c34KNfshmHK5jRdwv0P7Q4ac4v8omjXIK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJYTzhPAAoJELgmozMOVy/dvO8P/iv526m1kI+XOUI39jTtelm1
kxlMXgOh6UFTgPmv84Ml0N395XHQwklsyuW3WBSiyDyjOVpS2CeNWaLEH8k394ij
BJesEDkJXRX/soTYTGQHRIU1X1Po3xgliHK0upyB0DrdyAGlAs8pZI0ShxkuJ+Qr
mDtZxCiTfvuloghagipvxGA+QXq9HG4OaHa3YLlsNw5eKnEHF6oBdlyIUkI4aYla
gVvl/R2B4XnqDZtt1EEQImcPwWxe2sbUzTQ7cfdUKE8JRHtuqvC0LgSeTDXjvI/v
JOtB4gI2+y3WuRciocTtTjKpH54J9oWc9+QZ5XgNltKcTqVK57mIBqRwCRYwh6fm
r7CX+cRXcKcf9I6Gu8yDPAIZLRwNQtTaOf16P75rGv/iL0a0Kfe8UcHLFdrEb2fX
T5Xfz4wRaP2VcJKuD/x4rUbGobt7y9lIyQmvowmpprpB/rrlAoa7llXgAFkr6OHh
ZX56CyzuA4nNEihhmoBdlDBolzU5WORdAlEPqgDLuamRgWcDlmpj+ZBsz//wp+lW
fBMuU/44xN4HlGTyy9HfHlCIlRuwLEWPpbNeAqqYkyO311UeQya5xK3ZE6FFGlLI
lEDMKwnrKgB+wHKQn5S73pAjXkxtSUFXFr59OiNjkSGi0a/GjyXjvDe4+tm+VdB4
ahm1nNsjEzKAlOo9ZShm
=5tE0
-----END PGP SIGNATURE-----

--c34KNfshmHK5jRdwv0P7Q4ac4v8omjXIK--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
