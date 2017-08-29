From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: Permissions for eBPF objects
Date: Wed, 30 Aug 2017 00:23:50 +0200
Message-ID: <08c7118e-42cc-cd39-c076-8cf90fa0ee17@digikod.net>
References: <CABXk95AiYO7D8o79TBdt0_0g1TXfULSpL5i7KzHF3R4i-WhwHw@mail.gmail.com>
 <1503689199.9977.4.camel@tycho.nsa.gov>
 <CABXk95BkyU5MBLry0PEp+QwhtY7rM4DCmQq3CeQi6=TQtQQPwA@mail.gmail.com>
 <CAMOXUJkQ-Wh==9nzgx3Sq4RUEBK5ArHk4b=AL0N65L9g6cAqcg@mail.gmail.com>
 <59A0837F.9090301@iogearbox.net> <20170826010330.tuospq5h43fv3tlp@ast-mbp>
 <CAMOXUJ=kiZDEpuBfys0Me4o8wqSymCz+Eu_qdQdOH5+Czzfj8g@mail.gmail.com>
 <20170829011545.hjhpmyaerd44r5xo@ast-mbp>
 <CAMOXUJknLRNjtfQmFy65xiO974MhPK7As5D7La_3udqmS-BxNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="35fIEL7eu91c8HXmE0Fq8GaeAf7o3IGIw"
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Jeffrey Vander Stoep <jeffv@google.com>,
        Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>
To: Chenbo Feng <fengc@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh2.infomaniak.ch ([128.65.195.6]:35927 "EHLO
        smtp-sh2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdH2WY1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 18:24:27 -0400
In-Reply-To: <CAMOXUJknLRNjtfQmFy65xiO974MhPK7As5D7La_3udqmS-BxNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--35fIEL7eu91c8HXmE0Fq8GaeAf7o3IGIw
Content-Type: multipart/mixed; boundary="vp2isTQfEweDRI4bCHpenJF94GahUxjbP";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Chenbo Feng <fengc@google.com>,
 Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
 Jeffrey Vander Stoep <jeffv@google.com>, Stephen Smalley
 <sds@tycho.nsa.gov>, netdev@vger.kernel.org, SELinux <Selinux@tycho.nsa.gov>
Message-ID: <08c7118e-42cc-cd39-c076-8cf90fa0ee17@digikod.net>
Subject: Re: Permissions for eBPF objects
References: <CABXk95AiYO7D8o79TBdt0_0g1TXfULSpL5i7KzHF3R4i-WhwHw@mail.gmail.com>
 <1503689199.9977.4.camel@tycho.nsa.gov>
 <CABXk95BkyU5MBLry0PEp+QwhtY7rM4DCmQq3CeQi6=TQtQQPwA@mail.gmail.com>
 <CAMOXUJkQ-Wh==9nzgx3Sq4RUEBK5ArHk4b=AL0N65L9g6cAqcg@mail.gmail.com>
 <59A0837F.9090301@iogearbox.net> <20170826010330.tuospq5h43fv3tlp@ast-mbp>
 <CAMOXUJ=kiZDEpuBfys0Me4o8wqSymCz+Eu_qdQdOH5+Czzfj8g@mail.gmail.com>
 <20170829011545.hjhpmyaerd44r5xo@ast-mbp>
 <CAMOXUJknLRNjtfQmFy65xiO974MhPK7As5D7La_3udqmS-BxNg@mail.gmail.com>
In-Reply-To: <CAMOXUJknLRNjtfQmFy65xiO974MhPK7As5D7La_3udqmS-BxNg@mail.gmail.com>

--vp2isTQfEweDRI4bCHpenJF94GahUxjbP
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 29/08/2017 03:44, Chenbo Feng wrote:
> On Mon, Aug 28, 2017 at 6:15 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> On Mon, Aug 28, 2017 at 05:47:19PM -0700, Chenbo Feng wrote:
>>> On Fri, Aug 25, 2017 at 6:03 PM, Alexei Starovoitov
>>> <alexei.starovoitov@gmail.com> wrote:
>>>> On Fri, Aug 25, 2017 at 10:07:27PM +0200, Daniel Borkmann wrote:
>>>>> On 08/25/2017 09:52 PM, Chenbo Feng wrote:
>>>>>> On Fri, Aug 25, 2017 at 12:45 PM, Jeffrey Vander Stoep <jeffv@goog=
le.com> wrote:
>>>>>>> On Fri, Aug 25, 2017 at 12:26 PM, Stephen Smalley <sds@tycho.nsa.=
gov> wrote:
>>>>>>>> On Fri, 2017-08-25 at 11:01 -0700, Jeffrey Vander Stoep via Seli=
nux
>>>>>>>> wrote:
>>>>>>>>> I=E2=80=99d like to get your thoughts on adding LSM permission =
checks on BPF
>>>>>>>>> objects.
>>>>
>>>> before reinventing the wheel please take a look at landlock work.
>>>> Everything that was discussed in this thread is covered by it.
>>>> The patches have been in development for more than a year and most o=
f the early
>>>> issues have been resolved.
>>>> It will be presented again during security summit in LA in September=
=2E
>>>>
>>> I am not very familiar with landlock lsm, isn't this module also
>>> depend on the lsm hooks to do
>>> the landlock check? If so then adding lsm hooks for eBPF object seems=

>>> not conflict with the
>>> work on progress.
>>
>> I see. I got it the other way around. What lsm checks are you proposin=
g?
>> and why unprivileged_bpf_disabled is not enough?
>> you want to allow unpriv only for specific user(s) ?
>>
> Exactly, the proposal patch I am currently working on will add checks
> before map creation,
> map read,  and map modify, since all these functionalities will be
> available to all users when
> unprivileged_bpf_disabled is turned off. And eBPF prog_load may also
> need a check as well
> since loading some types of program is not restricted either.
>=20

It would be interesting to be able to check a wide range of actions
performed with the BPF syscall: the command and the union bpf_attr
argument. Because it is a multiplexer, that may be challenging, though.


--vp2isTQfEweDRI4bCHpenJF94GahUxjbP--

--35fIEL7eu91c8HXmE0Fq8GaeAf7o3IGIw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlml6XYACgkQIt7+33O9
apXi3Af/YYkcHzCQ9IpEcZl3kMHrTKzUDhGoziIAswCqRT/dyw3Gxa4Ar6BA/GlZ
HaUUBY6sWd5FI0wJJuK0D6BO0jZwp53lAYqsIckKpQi6g7C/bGeSbTDq1yXtYVfg
BT1ppSuaO0mEtyoYvlgwi1Wk3UYnU0djCE0ltpO1tPSSSEHXp8G0aJq4mj4kqCXU
Y9rOc1h5FKKmwtcxB7dRYb4XJiiFYnS5uLE8GA252AMc1gJt9dMcR0EmI0q7gRt4
6GmTR5af2yFvgMyNdqDr7Dh0md4np4b9p8AVbjdHClszB3Rrux8jQIzuk2XCJNqF
rp+G53Z4CMwMlndoY14hcBbgGd//xw==
=mEM+
-----END PGP SIGNATURE-----

--35fIEL7eu91c8HXmE0Fq8GaeAf7o3IGIw--
