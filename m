From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v4 00/18] Landlock LSM: Unprivileged sandboxing
Date: Mon, 14 Nov 2016 21:51:23 +0100
Message-ID: <582A23CB.5080506@digikod.net>
References: <20161026065654.19166-1-mic@digikod.net>
 <5828776A.1010104@digikod.net>
 <CAMp4zn8u3kg-nhiZ5rSUCLGveAzHr6FoP1x=iJasF2W0S56WfA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="m6axgi2XTbRK5v5hc0CrFcsnwFgFhv1rE"
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann
 <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com,
        Linux API <linux-api@vger.kernel.org>,
        LSM <linux-security-module@vger.kernel.org>,
        netdev
 <netdev@vger.kernel.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.ke
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <kernel-hardening-return-5336-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAMp4zn8u3kg-nhiZ5rSUCLGveAzHr6FoP1x=iJasF2W0S56WfA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--m6axgi2XTbRK5v5hc0CrFcsnwFgFhv1rE
Content-Type: multipart/mixed; boundary="arxkWoIbr02QlsTBHllefpbtpIGhIljxC";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Sargun Dhillon <sargun@sargun.me>
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann
 <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
 Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
 kernel-hardening@lists.openwall.com, Linux API <linux-api@vger.kernel.org>,
 LSM <linux-security-module@vger.kernel.org>, netdev
 <netdev@vger.kernel.org>,
 "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
Message-ID: <582A23CB.5080506@digikod.net>
Subject: Re: [RFC v4 00/18] Landlock LSM: Unprivileged sandboxing
References: <20161026065654.19166-1-mic@digikod.net>
 <5828776A.1010104@digikod.net>
 <CAMp4zn8u3kg-nhiZ5rSUCLGveAzHr6FoP1x=iJasF2W0S56WfA@mail.gmail.com>
In-Reply-To: <CAMp4zn8u3kg-nhiZ5rSUCLGveAzHr6FoP1x=iJasF2W0S56WfA@mail.gmail.com>

--arxkWoIbr02QlsTBHllefpbtpIGhIljxC
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 14/11/2016 11:35, Sargun Dhillon wrote:
> Was there a plan around getting Daniel's patches in as well? Also,
> rather than making these handles landlock-specific, can they be
> implemented in such a way where we can keep track of (some) of these
> in other types of programs?
>=20

About the map of handles, this is only a new type of map so it's not
particularly Landlock-specific. Anyway, we'll see that in the third step.=


 Micka=C3=ABl


--arxkWoIbr02QlsTBHllefpbtpIGhIljxC--

--m6axgi2XTbRK5v5hc0CrFcsnwFgFhv1rE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlgqI8sACgkQIt7+33O9
apU+2gf/RSjyuXmqh9+zIykIT/t4iMp3fCJR+HlDodTAGdp8PCVKYPQKJdbeYZih
GZ8N7biNbo94Ke3t/iZoW3D43y63ZZla9i3qmegbpT6o18IoCIvHA5kuJTMh5EtR
CKVPtiCw+GvKaUEtunrNeEJts0bztxwQPUa/0lQpLIbBJBrsuFtf7mTI17G1Aujc
L9BE3XnzWrphT7oCbkqaYhIV9Csl+6LbHp3oBNnQN3rI9VTh49/RIRNLeexflIDh
5VEq5MAQTvRrU5Nd9Ntc8Lik/pxa1dnjebFyeqsBXZArme5U8YKRVuChb3pEl3b5
3DjnRqCuaFOh8i2Coj7bs4o0/tNSCg==
=Yhft
-----END PGP SIGNATURE-----

--m6axgi2XTbRK5v5hc0CrFcsnwFgFhv1rE--
