From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH v5 06/10] seccomp,landlock: Handle Landlock events per
 process hierarchy
Date: Fri, 3 Mar 2017 02:05:00 +0100
Message-ID: <c10a503d-5e35-7785-2f3d-25ed8dd63fab@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-7-mic@digikod.net>
 <CALCETrWExjKHccdj-cYxPtis1NtXTPEYfReNLh065J1hHKvFiA@mail.gmail.com>
 <e6c917cb-d4a6-4147-9d6e-9c9fc906621d@digikod.net>
 <CALCETrWpXnFs3=tWjJSi6-E=XgbZVnq1p-Ty3BtPvXZawriHMw@mail.gmail.com>
 <db8cbaea-d4e5-3123-0b14-857737b753bc@digikod.net>
 <CALCETrXpaz3Sw8Q28PKi2LGB956bZ0mfhoNg59Pe5EY+kTmqZg@mail.gmail.com>
 <0efca89a-7e8b-a6f8-987b-95df61223a22@digikod.net>
 <CALCETrW8Pmap7CgdtE+XL39fPR1tOM4d8BBA=S4jot-ocAcw3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="h1o6JetnJJHplkmfCR84jD73o1MbWETmq"
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
Return-path: <kernel-hardening-return-6899-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrW8Pmap7CgdtE+XL39fPR1tOM4d8BBA=S4jot-ocAcw3g@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--h1o6JetnJJHplkmfCR84jD73o1MbWETmq
Content-Type: multipart/mixed; boundary="VeqrusUxPal7oWw0XahOVKqKvuigDfvKr";
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
 Network Development <netdev@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Message-ID: <c10a503d-5e35-7785-2f3d-25ed8dd63fab@digikod.net>
Subject: Re: [PATCH v5 06/10] seccomp,landlock: Handle Landlock events per
 process hierarchy
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-7-mic@digikod.net>
 <CALCETrWExjKHccdj-cYxPtis1NtXTPEYfReNLh065J1hHKvFiA@mail.gmail.com>
 <e6c917cb-d4a6-4147-9d6e-9c9fc906621d@digikod.net>
 <CALCETrWpXnFs3=tWjJSi6-E=XgbZVnq1p-Ty3BtPvXZawriHMw@mail.gmail.com>
 <db8cbaea-d4e5-3123-0b14-857737b753bc@digikod.net>
 <CALCETrXpaz3Sw8Q28PKi2LGB956bZ0mfhoNg59Pe5EY+kTmqZg@mail.gmail.com>
 <0efca89a-7e8b-a6f8-987b-95df61223a22@digikod.net>
 <CALCETrW8Pmap7CgdtE+XL39fPR1tOM4d8BBA=S4jot-ocAcw3g@mail.gmail.com>
In-Reply-To: <CALCETrW8Pmap7CgdtE+XL39fPR1tOM4d8BBA=S4jot-ocAcw3g@mail.gmail.com>

--VeqrusUxPal7oWw0XahOVKqKvuigDfvKr
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On 03/03/2017 01:55, Andy Lutomirski wrote:
> On Thu, Mar 2, 2017 at 4:48 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.n=
et> wrote:
>>
>> On 02/03/2017 17:36, Andy Lutomirski wrote:
>>> On Wed, Mar 1, 2017 at 3:28 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod=
=2Enet> wrote:
>>>>
>>>>
>>>> On 01/03/2017 23:20, Andy Lutomirski wrote:
>>>>> On Wed, Mar 1, 2017 at 2:14 PM, Micka=C3=ABl Sala=C3=BCn <mic@digik=
od.net> wrote:
>>>>>>
>>>>>> On 28/02/2017 21:01, Andy Lutomirski wrote:
>>>>>>> On Tue, Feb 21, 2017 at 5:26 PM, Micka=C3=ABl Sala=C3=BCn <mic@di=
gikod.net> wrote:
>>>>>> This design makes it possible for a process to add more constraint=
s to
>>>>>> its children on the fly. I think it is a good feature to have and =
a
>>>>>> safer default inheritance mechanism, but it could be guarded by an=

>>>>>> option flag if we want both mechanism to be available. The same de=
sign
>>>>>> could be used by seccomp filter too.
>>>>>>
>>>>>
>>>>> Then let's do it right.
>>>>>
>>>>> Currently each task has an array of seccomp filter layers.  When a
>>>>> task forks, the child inherits the layers.  All the layers are
>>>>> presently immutable.  With Landlock, a layer can logically be a
>>>>> syscall fitler layer or a Landlock layer.  This fits in to the
>>>>> existing model just fine.
>>>>>
>>>>> If we want to have an interface to allow modification of an existin=
g
>>>>> layer, let's make it so that, when a layer is added, you have to
>>>>> specify a flag to make the layer modifiable (by current, presumably=
,
>>>>> although I can imagine other policies down the road).  Then have a
>>>>> separate API that modifies a layer.
>>>>>
>>>>> IOW, I think your patch is bad for three reasons, all fixable:
>>>>>
>>>>> 1. The default is wrong.  A layer should be immutable to avoid an e=
asy
>>>>> attack in which you try to sandbox *yourself* and then you just mod=
ify
>>>>> the layer to weaken it.
>>>>
>>>> This is not possible, there is only an operation for now:
>>>> SECCOMP_ADD_LANDLOCK_RULE. You can only add more rules to the list (=
as
>>>> for seccomp filter). There is no way to weaken a sandbox. The questi=
on
>>>> is: how do we want to handle the rules *tree* (from the kernel point=
 of
>>>> view)?
>>>>
>>>
>>> Fair enough.  But I still think that immutability (like regular
>>> seccomp) should be the default.  For security, simplicity is
>>> important.  I guess there could be two ways to relax immutability:
>>> allowing making the layer stricter and allowing any change at all.
>>>
>>> As a default, though, programs should be able to expect that:
>>>
>>> seccomp(SECCOMP_ADD_WHATEVER, ...);
>>> fork();
>>>
>>> [parent gets compromised]
>>> [in parent]seccomp(anything whatsoever);
>>>
>>> will not affect the child,  If the parent wants to relax that, that's=

>>> fine, but I think it should be explicit.
>>
>> Good point. However the term "immutability" doesn't fit right because
>> the process is still allowed to add more rules to itself (as for
>> seccomp). The difference lays in the way a rule may be "appended" (by
>> the current process) or "inserted" (by a parent process).
>>
>> I think three or four kind of operations (through the seccomp syscall)=

>> make sense:
>> * append a rule (for the current process and its future children)
>=20
> Sure, but this operation should *never* affect existing children,
> existing seccomp layers, existing nodes, etc.  It should affect
> current and future children only.  Or it could simply not exist for
> Landlock and instead you'd have to add a layer (see below) and then
> program that layer.
>=20
>> * add a node (insert point), from which the inserted rules will be tie=
d
>> * insert a rule in the node, which will be inherited by futures childr=
en
>=20
> I would advocate calling this a "seccomp layer" and making creation
> and manipulation of them generic.
>=20
>> * (maybe a "lock" command to make a layer immutable for the current
>> process and its children)
>=20
> Hmm, maybe.
>=20
>>
>> Doing so, a process is only allowed to insert a rule if a node was
>> previously added. To forbid itself to insert new rules to one of its
>> children, a process just need to not add a node before forking. Like
>> this, there is no need for special rule flags nor default behavior,
>> everything is explicit.
>=20
> This is still slightly too complicated.  If you really want an
> operation that adds a layer (please don't call it a node in the ABI)
> and adds a rule to that layer in a single operation, it should be a
> separate operation.  Please make everything explicit.
>=20
> (I don't like exposing the word "node" to userspace because it means
> nothing.  Having more than one layer of filter makes sense to me,
> which is why I like "layer".  I'm sure that other good choices exist.)

I keep that for a future discussion, I'm now convinced the simple
inheritance (seccomp-like) doesn't block future extension.

>=20
>>
>> For this series, I will stick to the same behavior as seccomp filter:
>> only append rules to the current process (and its future children).
>>
>>
>>>>> 2. The API that adds a layer should be different from the API that
>>>>> modifies a layer.
>>>>
>>>> Right, but it doesn't apply now because we can only add rules.
>>>
>>> That's not what the code appears to do, though.  Sometimes it makes a=

>>> new layer without modifying tasks that share the layer and sometimes
>>> it modifies the layer.
>>>
>>> Both operations are probably okay, but they're not the same operation=

>>> and they shouldn't pretend to be.
>>
>> It should be OK with my previous proposal. The other details could be
>> discussed in a separate future patch series.
>>
>=20
> NAK, or at least NAK pending better docs and justification.  The
> operations of "add a layer and put a rule in it" and "add a rule to an
> existing layer" are logically different and should not be the same
> SECCOMP operation.

We are agree.

> "Do what I mean" is a nice paradigm for a language
> like Perl, but for security (and for kernel interfaces in general),
> "do what I say and error out if I said nonsense" is much safer.
>=20

Totally agree.


--VeqrusUxPal7oWw0XahOVKqKvuigDfvKr--

--h1o6JetnJJHplkmfCR84jD73o1MbWETmq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAli4wTwACgkQIt7+33O9
apV7xAf/VO80owTk0i08SKR2cfIEagE79se2A0rDo/hZ7JDa1IPfR0Hv962v6qVw
MqaU8TXH/ErGe0frLjiHyx7lIkncheToq9cLj18tbtKZHpvYIZOE+nChEkgs4PDb
4FAMBCGpZoho43V/CTEBDxd1Uj7Ai/Oyx7+DdH+qsPipvLlH3EsoeZlDIl71i8uT
X89YPRGNkNSTDkyd/sxmPQK+6cIMOOpNPChv0QB3QGF/gwEIW0fZp4PU1ksL4fK3
hxQpGfEKPFG2GbzrtqoH13kUcEI3YFGWTrEH6wKeMi1ue4P4vUAz1yxO9L7eCJy1
A7n40YpB08ha99ObaXNZnVYpNcVlig==
=d6AG
-----END PGP SIGNATURE-----

--h1o6JetnJJHplkmfCR84jD73o1MbWETmq--
