From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v4 00/18] Landlock LSM: Unprivileged sandboxing
Date: Wed, 26 Oct 2016 18:56:45 +0200
Message-ID: <5810E04D.9020300@digikod.net>
References: <20161026065654.19166-1-mic@digikod.net>
 <20161026145207.GM3334@pc.thejh.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="0g9em9kJcG2OCn0j7tG2Msjx06pnKq8aR"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann
 <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        cgroups@vger.kernel.org
To: Jann Horn <jann@thejh.net>
Return-path: <kernel-hardening-return-5048-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161026145207.GM3334@pc.thejh.net>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0g9em9kJcG2OCn0j7tG2Msjx06pnKq8aR
Content-Type: multipart/mixed; boundary="xSVaUqj13fXmEGcgfmugKc4o5kKiWNwan";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Jann Horn <jann@thejh.net>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann
 <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
 kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
 linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
 cgroups@vger.kernel.org
Message-ID: <5810E04D.9020300@digikod.net>
Subject: Re: [RFC v4 00/18] Landlock LSM: Unprivileged sandboxing
References: <20161026065654.19166-1-mic@digikod.net>
 <20161026145207.GM3334@pc.thejh.net>
In-Reply-To: <20161026145207.GM3334@pc.thejh.net>

--xSVaUqj13fXmEGcgfmugKc4o5kKiWNwan
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 26/10/2016 16:52, Jann Horn wrote:
> On Wed, Oct 26, 2016 at 08:56:36AM +0200, Micka=EBl Sala=FCn wrote:
>> The loaded Landlock eBPF programs can be triggered by a seccomp filter=

>> returning RET_LANDLOCK. In addition, a cookie (16-bit value) can be pa=
ssed from
>> a seccomp filter to eBPF programs. This allow flexible security polici=
es
>> between seccomp and Landlock.
>=20
> Is this still up to date, or was that removed in v3?
>=20

I forgot to remove this part. In this v4 series, as describe in the
(small) patch 11/18, a Landlock rule cannot be triggered by a seccomp
filter. So there is no more RET_LANDLOCK nor cookie.


--xSVaUqj13fXmEGcgfmugKc4o5kKiWNwan--

--0g9em9kJcG2OCn0j7tG2Msjx06pnKq8aR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJYEOBNAAoJECLe/t9zvWqVnG0H/36cN8uCe1TJ6AvbhMlqxv+e
7PmLgdJv/k1IXIFF8MDnna4TN7zsdL6mfNWPMtnOisRavTG+K2jUX66d01xmmP03
s97b7jxvMEh9/pBiUTeGW/5B6Q/7syt7O5hNJfawAGQQgpSvubay0FDYGCEubNaC
bSCG3yOJZ9dDvpx8SpyU7x9MaUaTjpG6NufHeMiF3LEmz195TmkCW9bWOOY/n5Po
iHKLB6PME0oYywX+T+F9Lct5iZ8nosNyz3iE2TB3sQTyI05ha2QxCUe6+qEzqYcM
NwTj1S/+rPWJnLeIP3RnNmm/z4hmwtH9Mpix2UptkC/z+zGWLBJQwmnRARuG3Ew=
=eMq7
-----END PGP SIGNATURE-----

--0g9em9kJcG2OCn0j7tG2Msjx06pnKq8aR--
