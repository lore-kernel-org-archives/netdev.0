From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: lsm naming dilemma. Re: [RFC v3 07/22] landlock: Handle file
 comparisons
Date: Tue, 20 Sep 2016 18:58:20 +0200
Message-ID: <57E16AAC.8000101@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-8-mic@digikod.net>
 <20160914210649.GA57174@ast-mbp.thefacebook.com>
 <57D9D6FE.4090708@digikod.net>
 <20160914232418.GD60248@ast-mbp.thefacebook.com>
 <57DB11B6.7090500@digikod.net>
 <20160920001215.GA91808@ast-mbp.thefacebook.com>
 <CAMp4zn8_GhvL5gGLrkADVSTP9Z4VO78bXtX8wbzFSa1P7j-yfA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="olXKeO7SERQb9SwC8GIlRu3AmCR5wBDTQ"
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, LSM <linux-security-module@vger.kernel.org>,
        netdev
 <netdev@vger.kernel.org>, cgroups@vge
To: Sargun Dhillon <sargun@sargun.me>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-4693-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAMp4zn8_GhvL5gGLrkADVSTP9Z4VO78bXtX8wbzFSa1P7j-yfA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--olXKeO7SERQb9SwC8GIlRu3AmCR5wBDTQ
Content-Type: multipart/mixed; boundary="TX4QiTbiBRxLVmGRpQT3K1PJN0rUPWeHf";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Sargun Dhillon <sargun@sargun.me>,
 Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, "Serge E . Hallyn" <serge@hallyn.com>,
 Tejun Heo <tj@kernel.org>, Will Drewry <wad@chromium.org>,
 kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
 LSM <linux-security-module@vger.kernel.org>, netdev
 <netdev@vger.kernel.org>, cgroups@vger.kernel.org
Message-ID: <57E16AAC.8000101@digikod.net>
Subject: Re: lsm naming dilemma. Re: [RFC v3 07/22] landlock: Handle file
 comparisons
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-8-mic@digikod.net>
 <20160914210649.GA57174@ast-mbp.thefacebook.com>
 <57D9D6FE.4090708@digikod.net>
 <20160914232418.GD60248@ast-mbp.thefacebook.com>
 <57DB11B6.7090500@digikod.net>
 <20160920001215.GA91808@ast-mbp.thefacebook.com>
 <CAMp4zn8_GhvL5gGLrkADVSTP9Z4VO78bXtX8wbzFSa1P7j-yfA@mail.gmail.com>
In-Reply-To: <CAMp4zn8_GhvL5gGLrkADVSTP9Z4VO78bXtX8wbzFSa1P7j-yfA@mail.gmail.com>

--TX4QiTbiBRxLVmGRpQT3K1PJN0rUPWeHf
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 20/09/2016 03:10, Sargun Dhillon wrote:
> I'm fine giving up the Checmate name. Landlock seems easy enough to
> Google. I haven't gotten a chance to look through the entire patchset
> yet, but it does seem like they are somewhat similar.

Excellent! I'm looking forward for your review.


>=20
> On Mon, Sep 19, 2016 at 5:12 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> On Thu, Sep 15, 2016 at 11:25:10PM +0200, Micka=C3=ABl Sala=C3=BCn wro=
te:
>>>>> Agreed. With this RFC, the Checmate features (i.e. network helpers)=

>>>>> should be able to sit on top of Landlock.
>>>>
>>>> I think neither of them should be called fancy names for no technica=
l reason.
>>>> We will have only one bpf based lsm. That's it and it doesn't
>>>> need an obscure name. Directory name can be security/bpf/..stuff.c
>>>
>>> I disagree on an LSM named "BPF". I first started with the "seccomp L=
SM"
>>> name (first RFC) but I later realized that it is confusing because
>>> seccomp is associated to its syscall and the underlying features. Sam=
e
>>> thing goes for BPF. It is also artificially hard to grep on a name to=
o
>>> used in the kernel source tree.
>>> Making an association between the generic eBPF mechanism and a securi=
ty
>>> centric approach (i.e. LSM) seems a bit reductive (for BPF). Moreover=
,
>>> the seccomp interface [1] can still be used.
>>
>> agree with above.
>>
>>> Landlock is a nice name to depict a sandbox as an enclave (i.e. a
>>> landlocked country/state). I want to keep this name, which is simple,=

>>> express the goal of Landlock nicely and is comparable to other sandbo=
x
>>> mechanisms as Seatbelt or Pledge.
>>> Landlock should not be confused with the underlying eBPF implementati=
on.
>>> Landlock could use more than only eBPF in the future and eBPF could b=
e
>>> used in other LSM as well.
>>
>> there will not be two bpf based LSMs.
>> Therefore unless you can convince Sargun to give up his 'checmate' nam=
e,
>> nothing goes in.
>> The features you both need are 90% the same, so they must be done
>> as part of single LSM whatever you both agree to call it.
>>
>=20


--TX4QiTbiBRxLVmGRpQT3K1PJN0rUPWeHf--

--olXKeO7SERQb9SwC8GIlRu3AmCR5wBDTQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX4WqsAAoJECLe/t9zvWqVRWkH/28QYuU/mHfIatrXwvfwXu7y
hkxNIv517JgeAtSIOwagTppbZRfBUtfAtRKvy/fOMd5Qac+qLx7oXq09Q3+hX8re
GPvUvzmawwE4c7DHxNu34Xg0U0Ci8CKZ17pJkFvDPlfHm945j6x8leSuLTkMv84T
F7JczUNtK6MM9PfMpdDeM1AWPGfzIxhCmwsSJpwP4oDcChpAwBvoYtyGf0NWN+Xa
W3BTecftSlrO6WL5cTbRf3CoGy/cNIbPUbOBGmebXh8Amio/TE4rkES2YJCxwKdF
5lB1bUvtuaVFBRo6Dr4wyk+I1dGpb5imYrxA8Gtt6xwzFzLNYVs5j2lwn+yOwNE=
=KSgS
-----END PGP SIGNATURE-----

--olXKeO7SERQb9SwC8GIlRu3AmCR5wBDTQ--
