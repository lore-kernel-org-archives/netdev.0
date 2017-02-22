From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH v5 10/10] landlock: Add user and kernel documentation for
 Landlock
Date: Wed, 22 Feb 2017 08:43:36 +0100
Message-ID: <b56c6abf-c8a5-d926-dcf7-0f0a6aa1334f@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-11-mic@digikod.net>
 <CALCETrXzL0VH_=QYHGXk1Y5P_yLyXdyTD-JVHVKTFf8F-AhYnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="tGg3IcwomGUQT68VU3TAp9B5Bf8VJvS4N"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale
 <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-6819-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrXzL0VH_=QYHGXk1Y5P_yLyXdyTD-JVHVKTFf8F-AhYnw@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--tGg3IcwomGUQT68VU3TAp9B5Bf8VJvS4N
Content-Type: multipart/mixed; boundary="cbPRXjXcN2xSAm0RUJKAOWc89xl1aH6LG";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, David Drysdale
 <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
 Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
 Michael Kerrisk <mtk.manpages@gmail.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
 Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
 Will Drewry <wad@chromium.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>
Message-ID: <b56c6abf-c8a5-d926-dcf7-0f0a6aa1334f@digikod.net>
Subject: Re: [PATCH v5 10/10] landlock: Add user and kernel documentation for
 Landlock
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-11-mic@digikod.net>
 <CALCETrXzL0VH_=QYHGXk1Y5P_yLyXdyTD-JVHVKTFf8F-AhYnw@mail.gmail.com>
In-Reply-To: <CALCETrXzL0VH_=QYHGXk1Y5P_yLyXdyTD-JVHVKTFf8F-AhYnw@mail.gmail.com>

--cbPRXjXcN2xSAm0RUJKAOWc89xl1aH6LG
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 22/02/2017 06:21, Andy Lutomirski wrote:
> On Tue, Feb 21, 2017 at 5:26 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>> This documentation can be built with the Sphinx framework.
>>
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: James Morris <james.l.morris@oracle.com>
>> Cc: Jonathan Corbet <corbet@lwn.net>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Serge E. Hallyn <serge@hallyn.com>
>=20
>=20
>> +
>> +Writing a rule
>> +--------------
>> +
>> +To enforce a security policy, a thread first needs to create a Landlo=
ck rule.
>> +The easiest way to write an eBPF program depicting a security rule is=
 to write
>> +it in the C language.  As described in *samples/bpf/README.rst*, LLVM=
 can
>> +compile such programs.  Files *samples/bpf/landlock1_kern.c* and thos=
e in
>> +*tools/testing/selftests/landlock/rules/* can be used as examples.  T=
he
>> +following example is a simple rule to forbid file creation, whatever =
syscall
>> +may be used (e.g. open, mkdir, link...).
>> +
>> +.. code-block:: c
>> +
>> +    static int deny_file_creation(struct landlock_context *ctx)
>> +    {
>> +        if (ctx->arg2 & LANDLOCK_ACTION_FS_NEW)
>> +            return 1;
>> +        return 0;
>> +    }
>> +
>=20
> Would it make sense to define landlock_context (or at least a prefix
> thereof) in here?  Also, can't "arg2" have a better name?

arg2 is a generic name. Its meaning depends on the Landlock event, here
it is an action bitfield (FS event).

>=20
> Can you specify what the return value means?  Are 0 and 1 the only
> choices?  Would "KILL" be useful?  How about "COREDUMP"?

This is explained thereafter and in the kernel Q&A section. I need to
briefly introduce that here.

>=20
>> +File system action types
>> +------------------------
>> +
>> +Flags are used to express actions.  This makes it possible to compose=
 actions
>> +and leaves room for future improvements to add more fine-grained acti=
on types.
>> +
>> +.. kernel-doc:: include/uapi/linux/bpf.h
>> +    :doc: landlock_action_fs
>> +
>> +.. flat-table:: FS action types availability
>> +
>> +    * - flags
>> +      - since
>> +
>> +    * - LANDLOCK_ACTION_FS_EXEC
>> +      - v1
>> +
>> +    * - LANDLOCK_ACTION_FS_WRITE
>> +      - v1
>> +
>> +    * - LANDLOCK_ACTION_FS_READ
>> +      - v1
>> +
>> +    * - LANDLOCK_ACTION_FS_NEW
>> +      - v1
>> +
>> +    * - LANDLOCK_ACTION_FS_GET
>> +      - v1
>> +
>> +    * - LANDLOCK_ACTION_FS_REMOVE
>> +      - v1
>> +
>> +    * - LANDLOCK_ACTION_FS_IOCTL
>> +      - v1
>> +
>> +    * - LANDLOCK_ACTION_FS_LOCK
>> +      - v1
>> +
>> +    * - LANDLOCK_ACTION_FS_FCNTL
>> +      - v1
>=20
> What happens if you run an old program on a new kernel?  Can you get
> unexpected action types?

The old flags will still make sense, the new ones should be ignored by
the rule.

>=20
>> +
>> +
>> +Ability types
>> +-------------
>> +
>> +The ability of a Landlock rule describes the available features (i.e.=
 context
>> +fields and helpers).  This is useful to abstract user-space privilege=
s for
>> +Landlock rules, which may not need all abilities (e.g. debug).  Only =
the
>> +minimal set of abilities should be used (e.g. disable debug once in
>> +production).
>> +
>> +
>> +.. kernel-doc:: include/uapi/linux/bpf.h
>> +    :doc: landlock_subtype_ability
>> +
>> +.. flat-table:: Ability types availability
>> +
>> +    * - flags
>> +      - since
>> +      - capability
>> +
>> +    * - LANDLOCK_SUBTYPE_ABILITY_WRITE
>> +      - v1
>> +      - CAP_SYS_ADMIN
>> +
>> +    * - LANDLOCK_SUBTYPE_ABILITY_DEBUG
>> +      - v1
>> +      - CAP_SYS_ADMIN
>> +
>=20
> What do "WRITE" and "DEBUG" mean in this context?  I'm totally lost.
>=20
> Hmm.  Reading below, "WRITE" seems to mean "modify state".  Would that
> be accurate?

That is correct, but handling a state in a safe way imply more than only
the ability to "write" outside bpfland (e.g. sequential execution).

>=20
>> +
>> +Helper functions
>> +----------------
>> +
>> +See *include/uapi/linux/bpf.h* for functions documentation.
>> +
>> +.. flat-table:: Generic functions availability
>> +
>=20
>> +
>> +    * - bpf_get_current_comm
>> +      - v1
>> +      - LANDLOCK_SUBTYPE_ABILITY_DEBUG
>=20
> What would this be used for?

To get more information about the process which trigger an action?

>=20
>> +    * - bpf_get_trace_printk
>> +      - v1
>> +      - LANDLOCK_SUBTYPE_ABILITY_DEBUG
>> +
>=20
> This is different from the other DEBUG stuff in that it has side
> effects.  I wonder if it should have a different flag.

I think the debug flag is a clear warning to not ship a rule using this
ability. Maybe a sub-flag LANDLOCK_SUBTYPE_ABILITY_DEBUG_PRINT would fit
here?

 Micka=C3=ABl


--cbPRXjXcN2xSAm0RUJKAOWc89xl1aH6LG--

--tGg3IcwomGUQT68VU3TAp9B5Bf8VJvS4N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlitQSgACgkQIt7+33O9
apWB7wgAjt9ZF2ZevHebsNpQegk6/vk/QVtydPq0smik9ZQaNc1Wea8yjxQ8CLfH
MdQc33U0JWPVC3b7i6+UDHTqHUj+LE07NOKkSO19PovaSGK3D4u5+KBe7kxcS2mi
NNuBxoNgQRzwTFaUqE2kAol7ZzR2kZYTWNLuQSTqDEVX8QwKyLF7Ap0J2iWzD6XN
entPzOhhbV/T3iwaTbNftc/OAz3wrwOaMwdL5/JJFvCPC0nEb1PBZdvudvpnDqYC
5sjn7oLXBjDSWnJJ3VwhStSbyGlWl73uqNJ2lg8t/t7BQItdPkKnnBSXC+PceeLQ
GsTOIDScGNdVkDtyhkCwLI5bUAoLmA==
=55lD
-----END PGP SIGNATURE-----

--tGg3IcwomGUQT68VU3TAp9B5Bf8VJvS4N--
