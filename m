From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
Date: Tue, 30 Aug 2016 22:33:31 +0200
Message-ID: <57C5ED9B.3040303@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C19E6E.6040908@digikod.net>
 <20160827180642.GA38754@ast-mbp.thefacebook.com>
 <57C1EB72.2050703@digikod.net>
 <20160827204307.GA43714@ast-mbp.thefacebook.com>
 <57C202BF.7000207@digikod.net>
 <CALCETrXgQ+njtupXiKcOXG8ZRzD=n2LhT45NiJr1Ehob7bHskQ@mail.gmail.com>
 <57C2B21E.9040705@digikod.net>
 <CALCETrXU64+UApeKL_NogpBYk5kN7zA7UwkypZt8SYfvkuQrbA@mail.gmail.com>
 <57C5EAA3.5090901@digikod.net>
 <CALCETrWAYyx_5Axyeqiz6tQa0kqTeNTuHRrERcM2G8ROhaphVw@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="hDDIrGxJRpIt6vRfVGBWKpUs0EVaGh6mj"
Cc: "kernel-hardening@lists.openwall.com"
 <kernel-hardening@lists.openwall.com>,
        Alexei Starovoitov <ast@kernel.org>, Tejun Heo <tj@kernel.org>,
        Sargun Dhillon <sargun@sargun.me>,
        Network Development <netdev@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Mack <daniel@zonque.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4515-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrWAYyx_5Axyeqiz6tQa0kqTeNTuHRrERcM2G8ROhaphVw@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--hDDIrGxJRpIt6vRfVGBWKpUs0EVaGh6mj
Content-Type: multipart/mixed; boundary="KDabwbi0WRAbEcmcNH0So8fpj4a89pDO6";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "kernel-hardening@lists.openwall.com"
 <kernel-hardening@lists.openwall.com>, Alexei Starovoitov <ast@kernel.org>,
 Tejun Heo <tj@kernel.org>, Sargun Dhillon <sargun@sargun.me>,
 Network Development <netdev@vger.kernel.org>,
 Linux API <linux-api@vger.kernel.org>, Kees Cook <keescook@chromium.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
 "David S . Miller" <davem@davemloft.net>, Daniel Mack <daniel@zonque.org>,
 Alexei Starovoitov <alexei.starovoitov@gmail.com>,
 Daniel Borkmann <daniel@iogearbox.net>
Message-ID: <57C5ED9B.3040303@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C19E6E.6040908@digikod.net>
 <20160827180642.GA38754@ast-mbp.thefacebook.com>
 <57C1EB72.2050703@digikod.net>
 <20160827204307.GA43714@ast-mbp.thefacebook.com>
 <57C202BF.7000207@digikod.net>
 <CALCETrXgQ+njtupXiKcOXG8ZRzD=n2LhT45NiJr1Ehob7bHskQ@mail.gmail.com>
 <57C2B21E.9040705@digikod.net>
 <CALCETrXU64+UApeKL_NogpBYk5kN7zA7UwkypZt8SYfvkuQrbA@mail.gmail.com>
 <57C5EAA3.5090901@digikod.net>
 <CALCETrWAYyx_5Axyeqiz6tQa0kqTeNTuHRrERcM2G8ROhaphVw@mail.gmail.com>
In-Reply-To: <CALCETrWAYyx_5Axyeqiz6tQa0kqTeNTuHRrERcM2G8ROhaphVw@mail.gmail.com>

--KDabwbi0WRAbEcmcNH0So8fpj4a89pDO6
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On 30/08/2016 22:23, Andy Lutomirski wrote:
> On Tue, Aug 30, 2016 at 1:20 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>
>> On 30/08/2016 20:55, Andy Lutomirski wrote:
>>> On Sun, Aug 28, 2016 at 2:42 AM, Micka=C3=ABl Sala=C3=BCn <mic@digiko=
d.net> wrote:
>>>>
>>>>
>>>> On 28/08/2016 10:13, Andy Lutomirski wrote:
>>>>> On Aug 27, 2016 11:14 PM, "Micka=C3=ABl Sala=C3=BCn" <mic@digikod.n=
et> wrote:
>>>>>>
>>>>>>
>>>>>> On 27/08/2016 22:43, Alexei Starovoitov wrote:
>>>>>>> On Sat, Aug 27, 2016 at 09:35:14PM +0200, Micka=C3=ABl Sala=C3=BC=
n wrote:
>>>>>>>> On 27/08/2016 20:06, Alexei Starovoitov wrote:
>>>>>>>>> On Sat, Aug 27, 2016 at 04:06:38PM +0200, Micka=C3=ABl Sala=C3=BC=
n wrote:
>>>>>>>>>> As said above, Landlock will not run an eBPF programs when not=
 strictly
>>>>>>>>>> needed. Attaching to a cgroup will have the same performance i=
mpact as
>>>>>>>>>> attaching to a process hierarchy.
>>>>>>>>>
>>>>>>>>> Having a prog per cgroup per lsm_hook is the only scalable way =
I
>>>>>>>>> could come up with. If you see another way, please propose.
>>>>>>>>> current->seccomp.landlock_prog is not the answer.
>>>>>>>>
>>>>>>>> Hum, I don't see the difference from a performance point of view=
 between
>>>>>>>> a cgroup-based or a process hierarchy-based system.
>>>>>>>>
>>>>>>>> Maybe a better option should be to use an array of pointers with=
 N
>>>>>>>> entries, one for each supported hook, instead of a unique pointe=
r list?
>>>>>>>
>>>>>>> yes, clearly array dereference is faster than link list walk.
>>>>>>> Now the question is where to keep this prog_array[num_lsm_hooks] =
?
>>>>>>> Since we cannot keep it inside task_struct, we have to allocate i=
t.
>>>>>>> Every time the task is creted then. What to do on the fork? That
>>>>>>> will require changes all over. Then the obvious optimization woul=
d be
>>>>>>> to share this allocated array of prog pointers across multiple ta=
sks...
>>>>>>> and little by little this new facility will look like cgroup.
>>>>>>> Hence the suggestion to put this array into cgroup from the start=
=2E
>>>>>>
>>>>>> I see your point :)
>>>>>>
>>>>>>>
>>>>>>>> Anyway, being able to attach an LSM hook program to a cgroup tha=
nks to
>>>>>>>> the new BPF_PROG_ATTACH seems a good idea (while keeping the pos=
sibility
>>>>>>>> to use a process hierarchy). The downside will be to handle an L=
SM hook
>>>>>>>> program which is not triggered by a seccomp-filter, but this sho=
uld be
>>>>>>>> needed anyway to handle interruptions.
>>>>>>>
>>>>>>> what do you mean 'not triggered by seccomp' ?
>>>>>>> You're not suggesting that this lsm has to enable seccomp to be f=
unctional?
>>>>>>> imo that's non starter due to overhead.
>>>>>>
>>>>>> Yes, for now, it is triggered by a new seccomp filter return value=

>>>>>> RET_LANDLOCK, which can take a 16-bit value called cookie. This mu=
st not
>>>>>> be needed but could be useful to bind a seccomp filter security po=
licy
>>>>>> with a Landlock one. Waiting for Kees's point of view=E2=80=A6
>>>>>>
>>>>>
>>>>> I'm not Kees, but I'd be okay with that.  I still think that doing
>>>>> this by process hierarchy a la seccomp will be easier to use and to=

>>>>> understand (which is quite important for this kind of work) than do=
ing
>>>>> it by cgroup.
>>>>>
>>>>> A feature I've wanted to add for a while is to have an fd that
>>>>> represents a seccomp layer, the idea being that you would set up yo=
ur
>>>>> seccomp layer (with syscall filter, landlock hooks, etc) and then y=
ou
>>>>> would have a syscall to install that layer.  Then an unprivileged
>>>>> sandbox manager could set up its layer and still be able to inject =
new
>>>>> processes into it later on, no cgroups needed.
>>>>
>>>> A nice thing I didn't highlight about Landlock is that a process can=

>>>> prepare a layer of rules (arraymap of handles + Landlock programs) a=
nd
>>>> pass the file descriptors of the Landlock programs to another proces=
s.
>>>> This process could then apply this programs to get sandboxed. Howeve=
r,
>>>> for now, because a Landlock program is only triggered by a seccomp
>>>> filter (which do not follow the Landlock programs as a FD), they wil=
l be
>>>> useless.
>>>>
>>>> The FD referring to an arraymap of handles can also be used to updat=
e a
>>>> map and change the behavior of a Landlock program. A master process =
can
>>>> then add or remove restrictions to another process hierarchy on the =
fly.
>>>
>>> Maybe this could be extended a little bit.  The fd could hold the
>>> seccomp filter *and* the LSM hook filters.  FMODE_EXECUTE could give
>>> the ability to install it and FMODE_WRITE could give the ability to
>>> modify it.
>>>
>>
>> This is interesting! It should be possible to append the seccomp stack=

>> of a source process to the seccomp stack of the target process when a
>> Landlock program is passed and then activated through seccomp(2).
>>
>> For the FMODE_EXECUTE/FMODE_WRITE, are you suggesting to manage
>> permission of the eBPF program FD in a specific way?
>>
>=20
> This wouldn't be an eBPF program FD -- it would be an FD encapsulating
> an entire configuration including seccomp BPF program, whatever
> landlock stuff is associated, and eventual seccomp monitor
> configuration (once I write that code), etc.
>=20
> You wouldn't say "attach this process's seccomp stack to me" -- you'd
> say "attach this seccomp layer to me".
>=20
> A decision that we'd have to make would be whether the FD links to the
> parent layer or whether it can be attached without regard to what the
> parent layer is.

OK, I like that, but I think it could be done on a second time. :)


--KDabwbi0WRAbEcmcNH0So8fpj4a89pDO6--

--hDDIrGxJRpIt6vRfVGBWKpUs0EVaGh6mj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXxe2bAAoJECLe/t9zvWqVVE0IAJswaPMthFETHRBviRFW6dVw
XIxJrXJf+qnSVqoMhiN9xWNEUxz0kCUAoGwx0pUEGzvxqn13/oMRfFEhEx8ssXaL
TBzcuBa1dAFehh9wyrCIEmwmswcSnWnfJ28OHFHgLKplDc55jKnz+ysuikXzyXWg
+sIiLLqs6DmIGerft/1jHqAryYFm1iWPkgfYFja5o0IhqYH+Fwgz9TT+eg7t9OKD
/1J3C3g+A9V2vrbcTf2sUHy8CUm7deXxwY7AdqCgkU63sqf20IZl1XvWzkGU5zhG
/EJ3j6Wg0GLZa7nMTew/am78PHXAqsh9UaBDM/ZXIMWtSKO2m3NdQn17wLX+lhM=
=yT1s
-----END PGP SIGNATURE-----

--hDDIrGxJRpIt6vRfVGBWKpUs0EVaGh6mj--
