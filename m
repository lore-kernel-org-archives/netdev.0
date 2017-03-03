From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH v5 06/10] seccomp,landlock: Handle Landlock events per
 process hierarchy
Date: Fri, 3 Mar 2017 01:48:20 +0100
Message-ID: <0efca89a-7e8b-a6f8-987b-95df61223a22@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-7-mic@digikod.net>
 <CALCETrWExjKHccdj-cYxPtis1NtXTPEYfReNLh065J1hHKvFiA@mail.gmail.com>
 <e6c917cb-d4a6-4147-9d6e-9c9fc906621d@digikod.net>
 <CALCETrWpXnFs3=tWjJSi6-E=XgbZVnq1p-Ty3BtPvXZawriHMw@mail.gmail.com>
 <db8cbaea-d4e5-3123-0b14-857737b753bc@digikod.net>
 <CALCETrXpaz3Sw8Q28PKi2LGB956bZ0mfhoNg59Pe5EY+kTmqZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="SL7OmR0nTFnO4kcUa50oI0qtiRUGEqFot"
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
Return-path: <kernel-hardening-return-6895-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrXpaz3Sw8Q28PKi2LGB956bZ0mfhoNg59Pe5EY+kTmqZg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SL7OmR0nTFnO4kcUa50oI0qtiRUGEqFot
Content-Type: multipart/mixed; boundary="UBQf3sDLgTQe2EEjbbJaqHB58O6DtaRTG";
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
Message-ID: <0efca89a-7e8b-a6f8-987b-95df61223a22@digikod.net>
Subject: Re: [PATCH v5 06/10] seccomp,landlock: Handle Landlock events per
 process hierarchy
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-7-mic@digikod.net>
 <CALCETrWExjKHccdj-cYxPtis1NtXTPEYfReNLh065J1hHKvFiA@mail.gmail.com>
 <e6c917cb-d4a6-4147-9d6e-9c9fc906621d@digikod.net>
 <CALCETrWpXnFs3=tWjJSi6-E=XgbZVnq1p-Ty3BtPvXZawriHMw@mail.gmail.com>
 <db8cbaea-d4e5-3123-0b14-857737b753bc@digikod.net>
 <CALCETrXpaz3Sw8Q28PKi2LGB956bZ0mfhoNg59Pe5EY+kTmqZg@mail.gmail.com>
In-Reply-To: <CALCETrXpaz3Sw8Q28PKi2LGB956bZ0mfhoNg59Pe5EY+kTmqZg@mail.gmail.com>

--UBQf3sDLgTQe2EEjbbJaqHB58O6DtaRTG
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 02/03/2017 17:36, Andy Lutomirski wrote:
> On Wed, Mar 1, 2017 at 3:28 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.n=
et> wrote:
>>
>>
>> On 01/03/2017 23:20, Andy Lutomirski wrote:
>>> On Wed, Mar 1, 2017 at 2:14 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod=
=2Enet> wrote:
>>>>
>>>> On 28/02/2017 21:01, Andy Lutomirski wrote:
>>>>> On Tue, Feb 21, 2017 at 5:26 PM, Micka=C3=ABl Sala=C3=BCn <mic@digi=
kod.net> wrote:
>>>> This design makes it possible for a process to add more constraints =
to
>>>> its children on the fly. I think it is a good feature to have and a
>>>> safer default inheritance mechanism, but it could be guarded by an
>>>> option flag if we want both mechanism to be available. The same desi=
gn
>>>> could be used by seccomp filter too.
>>>>
>>>
>>> Then let's do it right.
>>>
>>> Currently each task has an array of seccomp filter layers.  When a
>>> task forks, the child inherits the layers.  All the layers are
>>> presently immutable.  With Landlock, a layer can logically be a
>>> syscall fitler layer or a Landlock layer.  This fits in to the
>>> existing model just fine.
>>>
>>> If we want to have an interface to allow modification of an existing
>>> layer, let's make it so that, when a layer is added, you have to
>>> specify a flag to make the layer modifiable (by current, presumably,
>>> although I can imagine other policies down the road).  Then have a
>>> separate API that modifies a layer.
>>>
>>> IOW, I think your patch is bad for three reasons, all fixable:
>>>
>>> 1. The default is wrong.  A layer should be immutable to avoid an eas=
y
>>> attack in which you try to sandbox *yourself* and then you just modif=
y
>>> the layer to weaken it.
>>
>> This is not possible, there is only an operation for now:
>> SECCOMP_ADD_LANDLOCK_RULE. You can only add more rules to the list (as=

>> for seccomp filter). There is no way to weaken a sandbox. The question=

>> is: how do we want to handle the rules *tree* (from the kernel point o=
f
>> view)?
>>
>=20
> Fair enough.  But I still think that immutability (like regular
> seccomp) should be the default.  For security, simplicity is
> important.  I guess there could be two ways to relax immutability:
> allowing making the layer stricter and allowing any change at all.
>=20
> As a default, though, programs should be able to expect that:
>=20
> seccomp(SECCOMP_ADD_WHATEVER, ...);
> fork();
>=20
> [parent gets compromised]
> [in parent]seccomp(anything whatsoever);
>=20
> will not affect the child,  If the parent wants to relax that, that's
> fine, but I think it should be explicit.

Good point. However the term "immutability" doesn't fit right because
the process is still allowed to add more rules to itself (as for
seccomp). The difference lays in the way a rule may be "appended" (by
the current process) or "inserted" (by a parent process).

I think three or four kind of operations (through the seccomp syscall)
make sense:
* append a rule (for the current process and its future children)
* add a node (insert point), from which the inserted rules will be tied
* insert a rule in the node, which will be inherited by futures children
* (maybe a "lock" command to make a layer immutable for the current
process and its children)

Doing so, a process is only allowed to insert a rule if a node was
previously added. To forbid itself to insert new rules to one of its
children, a process just need to not add a node before forking. Like
this, there is no need for special rule flags nor default behavior,
everything is explicit.

For this series, I will stick to the same behavior as seccomp filter:
only append rules to the current process (and its future children).


>>> 2. The API that adds a layer should be different from the API that
>>> modifies a layer.
>>
>> Right, but it doesn't apply now because we can only add rules.
>=20
> That's not what the code appears to do, though.  Sometimes it makes a
> new layer without modifying tasks that share the layer and sometimes
> it modifies the layer.
>=20
> Both operations are probably okay, but they're not the same operation
> and they shouldn't pretend to be.

It should be OK with my previous proposal. The other details could be
discussed in a separate future patch series.


>>> 3. The whole modification mechanism should be a separate patch to be
>>> reviewed on its own merits.
>>
>> For a rule *replacement*, sure!
>=20
> And for modification of policy for non-current tasks.  That's a big
> departure from normal seccomp and should be reviewed as such.

Agreed


--UBQf3sDLgTQe2EEjbbJaqHB58O6DtaRTG--

--SL7OmR0nTFnO4kcUa50oI0qtiRUGEqFot
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAli4vVQACgkQIt7+33O9
apWwGAf+I+HIdh4cRyaIRbDyKvEfvhniKypbdKlaz8U23K/9cOUlYImDKQX5sm/G
hpFQTlMJEMqT5+DT5vyIjZAD9DxvXCMfT1e3hawYktg9CLr2nD4D1hGpuZl+F9qL
v9dnyukudHj9Vo6+KrJ2TnOfeGohj3fa63nWNkTva6gzS1nnUDk6WZJDqd+XrSZW
W9YjL/fm+ffv/SoxRNoYkyDiBtvThTxluNKuCa2fAphFU2CFLQPJGmPLS4sraKja
uH0wZDgAP2j+aQOsEy9nb7kPWja4Di/aYrppHbnur+hquV2Bd7kDsuIh7w4LRrVQ
ANbeufctMjPv4j7eVT8NL9rj2rs+yQ==
=UhYh
-----END PGP SIGNATURE-----

--SL7OmR0nTFnO4kcUa50oI0qtiRUGEqFot--
