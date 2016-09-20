From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
Date: Tue, 20 Sep 2016 19:02:11 +0200
Message-ID: <57E16B93.8060702@digikod.net>
References: <57D9CB25.1010103@digikod.net>
 <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
 <20160915021940.GA65119@ast-mbp.thefacebook.com>
 <CALCETrWXjJZZRj5XvDQ+-Grue+b4MW2TFKsfgYYFYoFBFVH71g@mail.gmail.com>
 <20160915040054.GA65308@ast-mbp.thefacebook.com>
 <CALCETrXTS8R1E2b9mmWzpOO6QOW5nWYW_RQRJYU1CGRsbNy+Yw@mail.gmail.com>
 <20160915043120.GA65819@ast-mbp.thefacebook.com>
 <CALCETrU=tGLx8s_eqji6SfXRi=3W8FkGC7wA6VMfD-_wAVb66w@mail.gmail.com>
 <20160915044852.GA66000@ast-mbp.thefacebook.com>
 <57DAF96D.3060609@digikod.net>
 <20160920043744.GA13906@ircssh.c.rugged-nimbus-611.internal>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="J7enpp3EX8Cu2vSrxjSWFqMhN89rOenTJ"
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@amacapital.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
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
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwal
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <kernel-hardening-return-4694-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160920043744.GA13906@ircssh.c.rugged-nimbus-611.internal>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--J7enpp3EX8Cu2vSrxjSWFqMhN89rOenTJ
Content-Type: multipart/mixed; boundary="qAWCui2q1mvk0xkW4k6GHPgW29ed4OEbo";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
 Andy Lutomirski <luto@amacapital.net>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, "Serge E . Hallyn" <serge@hallyn.com>,
 Tejun Heo <tj@kernel.org>, Will Drewry <wad@chromium.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>,
 "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
Message-ID: <57E16B93.8060702@digikod.net>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
References: <57D9CB25.1010103@digikod.net>
 <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
 <20160915021940.GA65119@ast-mbp.thefacebook.com>
 <CALCETrWXjJZZRj5XvDQ+-Grue+b4MW2TFKsfgYYFYoFBFVH71g@mail.gmail.com>
 <20160915040054.GA65308@ast-mbp.thefacebook.com>
 <CALCETrXTS8R1E2b9mmWzpOO6QOW5nWYW_RQRJYU1CGRsbNy+Yw@mail.gmail.com>
 <20160915043120.GA65819@ast-mbp.thefacebook.com>
 <CALCETrU=tGLx8s_eqji6SfXRi=3W8FkGC7wA6VMfD-_wAVb66w@mail.gmail.com>
 <20160915044852.GA66000@ast-mbp.thefacebook.com>
 <57DAF96D.3060609@digikod.net>
 <20160920043744.GA13906@ircssh.c.rugged-nimbus-611.internal>
In-Reply-To: <20160920043744.GA13906@ircssh.c.rugged-nimbus-611.internal>

--qAWCui2q1mvk0xkW4k6GHPgW29ed4OEbo
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 20/09/2016 06:37, Sargun Dhillon wrote:
> On Thu, Sep 15, 2016 at 09:41:33PM +0200, Micka=EBl Sala=FCn wrote:
>>
>> On 15/09/2016 06:48, Alexei Starovoitov wrote:
>>> On Wed, Sep 14, 2016 at 09:38:16PM -0700, Andy Lutomirski wrote:
>>>> On Wed, Sep 14, 2016 at 9:31 PM, Alexei Starovoitov
>>>> <alexei.starovoitov@gmail.com> wrote:
>>>>> On Wed, Sep 14, 2016 at 09:08:57PM -0700, Andy Lutomirski wrote:
>>>>>> On Wed, Sep 14, 2016 at 9:00 PM, Alexei Starovoitov
>>>>>> <alexei.starovoitov@gmail.com> wrote:
>>>>>>> On Wed, Sep 14, 2016 at 07:27:08PM -0700, Andy Lutomirski wrote:
>>>>>>>>>>>
>>>>>>>>>>> This RFC handle both cgroup and seccomp approaches in a simil=
ar way. I
>>>>>>>>>>> don't see why building on top of cgroup v2 is a problem. Is t=
here
>>>>>>>>>>> security issues with delegation?
>>>>>>>>>>
>>>>>>>>>> What I mean is: cgroup v2 delegation has a functionality probl=
em.
>>>>>>>>>> Tejun says [1]:
>>>>>>>>>>
>>>>>>>>>> We haven't had to face this decision because cgroup has never =
properly
>>>>>>>>>> supported delegating to applications and the in-use setups whe=
re this
>>>>>>>>>> happens are custom configurations where there is no boundary b=
etween
>>>>>>>>>> system and applications and adhoc trial-and-error is good enou=
gh a way
>>>>>>>>>> to find a working solution.  That wiggle room goes away once w=
e
>>>>>>>>>> officially open this up to individual applications.
>>>>>>>>>>
>>>>>>>>>> Unless and until that changes, I think that landlock should st=
ay away
>>>>>>>>>> from cgroups.  Others could reasonably disagree with me.
>>>>>>>>>
>>>>>>>>> Ours and Sargun's use cases for cgroup+lsm+bpf is not for secur=
ity
>>>>>>>>> and not for sandboxing. So the above doesn't matter in such con=
texts.
>>>>>>>>> lsm hooks + cgroups provide convenient scope and existing entry=
 points.
>>>>>>>>> Please see checmate examples how it's used.
>>>>>>>>>
>>>>>>>>
>>>>>>>> To be clear: I'm not arguing at all that there shouldn't be
>>>>>>>> bpf+lsm+cgroup integration.  I'm arguing that the unprivileged
>>>>>>>> landlock interface shouldn't expose any cgroup integration, at l=
east
>>>>>>>> until the cgroup situation settles down a lot.
>>>>>>>
>>>>>>> ahh. yes. we're perfectly in agreement here.
>>>>>>> I'm suggesting that the next RFC shouldn't include unpriv
>>>>>>> and seccomp at all. Once bpf+lsm+cgroup is merged, we can
>>>>>>> argue about unpriv with cgroups and even unpriv as a whole,
>>>>>>> since it's not a given. Seccomp integration is also questionable.=

>>>>>>> I'd rather not have seccomp as a gate keeper for this lsm.
>>>>>>> lsm and seccomp are orthogonal hook points. Syscalls and lsm hook=
s
>>>>>>> don't have one to one relationship, so mixing them up is only
>>>>>>> asking for trouble further down the road.
>>>>>>> If we really need to carry some information from seccomp to lsm+b=
pf,
>>>>>>> it's easier to add eBPF support to seccomp and let bpf side deal
>>>>>>> with passing whatever information.
>>>>>>>
>>>>>>
>>>>>> As an argument for keeping seccomp (or an extended seccomp) as the=

>>>>>> interface for an unprivileged bpf+lsm: seccomp already checks off =
most
>>>>>> of the boxes for safely letting unprivileged programs sandbox
>>>>>> themselves.
>>>>>
>>>>> you mean the attach part of seccomp syscall that deals with no_new_=
priv?
>>>>> sure, that's reusable.
>>>>>
>>>>>> Furthermore, to the extent that there are use cases for
>>>>>> unprivileged bpf+lsm that *aren't* expressible within the seccomp
>>>>>> hierarchy, I suspect that syscall filters have exactly the same
>>>>>> problem and that we should fix seccomp to cover it.
>>>>>
>>>>> not sure what you mean by 'seccomp hierarchy'. The normal process
>>>>> hierarchy ?
>>>>
>>>> Kind of.  I mean the filter layers that are inherited across fork(),=

>>>> the TSYNC mechanism, etc.
>>>>
>>>>> imo the main deficiency of secccomp is inability to look into argum=
ents.
>>>>> One can argue that it's a blessing, since composite args
>>>>> are not yet copied into the kernel memory.
>>>>> But in a lot of cases the seccomp arguments are FDs pointing
>>>>> to kernel objects and if programs could examine those objects
>>>>> the sandboxing scope would be more precise.
>>>>> lsm+bpf solves that part and I'd still argue that it's
>>>>> orthogonal to seccomp's pass/reject flow.
>>>>> I mean if seccomp says 'ok' the syscall should continue executing
>>>>> as normal and whatever LSM hooks were triggered by it may have
>>>>> their own lsm+bpf verdicts.
>>>>
>>>> I agree with all of this...
>>>>
>>>>> Furthermore in the process hierarchy different children
>>>>> should be able to set their own lsm+bpf filters that are not
>>>>> related to parallel seccomp+bpf hierarchy of programs.
>>>>> seccomp syscall can be an interface to attach programs
>>>>> to lsm hooks, but nothing more than that.
>>>>
>>>> I'm not sure what you mean.  I mean that, logically, I think we shou=
ld
>>>> be able to do:
>>>>
>>>> seccomp(attach a syscall filter);
>>>> fork();
>>>> child does seccomp(attach some lsm filters);
>>>>
>>>> I think that they *should* be related to the seccomp+bpf hierarchy o=
f
>>>> programs in that they are entries in the same logical list of filter=

>>>> layers installed.  Some of those layers can be syscall filters and
>>>> some of the layers can be lsm filters.  If we subsequently add a way=

>>>> to attach a removable seccomp filter or a way to attach a seccomp
>>>> filter that logs failures to some fd watched by an outside monitor, =
I
>>>> think that should work for lsm, too, with more or less the same
>>>> interface.
>>>>
>>>> If we need a way for a sandbox manager to opt different children int=
o
>>>> different subsets of fancy filters, then I think that syscall filter=
s
>>>> and lsm filters should use the same mechanism.
>>>>
>>>> I think we might be on the same page here and just saying it differe=
nt ways.
>>>
>>> Sounds like it :)
>>> All of the above makes sense to me.
>>> The 'orthogonal' part is that the user should be able to use
>>> this seccomp-managed hierarchy without actually enabling
>>> TIF_SECCOMP for the task and syscalls should still go through
>>> fast path and all the way till lsm hooks as normal.
>>> I don't want to pay _any_ performance penalty for this feature
>>> for lsm hooks (and all syscalls) that don't have bpf programs attache=
d.
>>
>> Yes, it seems that we are all on the same page here, and that match th=
is
>> RFC implementation. So, using the seccomp(2) *interface* to attach
>> Landlock programs to a process hierarchy is still on track. :)
>>
>=20
> So, I'm catching up on this after a little while away. I really like th=
e=20
> simplicity of the approach Daniel took with his patches. I began to hav=
e=20
> difficulty reading your patchset once you got into using seccomp + unpr=
ivileged=20
> mode. I would love to see a separate patchset that only have the verifi=
er, and
> lsm hook changes. Do you think you could decompose your patchset into a=
n MVP?
>=20

OK, I'll try to split the common parts from the seccomp part, but there
is already a dedicated patch for the LSM hooks [06/22].


--qAWCui2q1mvk0xkW4k6GHPgW29ed4OEbo--

--J7enpp3EX8Cu2vSrxjSWFqMhN89rOenTJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX4WuTAAoJECLe/t9zvWqVHOcH/1Zptejxs05//L8mRiGRR/3N
Ap5hJEeUX8XYZhWWIg4ULPbInafd1+FqX+NINMApu8lJlFCTKAfkjZHNl1ekEzkw
dg0xHl+5IFpnozEhbbYvH5RRene3qg0CpBPt4SsvGNA9hbwgObMPXOE6ZU9ccL4L
zyqAUrapNL+gwT6GKbR/cNmk/PIheNJSU4cMcim2IzW6pEp5AiXEgjXV8jUwt2S8
8YI/3eArip1XOHYC97PSkZJS6W8Mn0i8RssfxvUy4IUdOji+VaMDwKehl/FdJVw/
nCbp/WSWHMAe3MY2xjitSvG71s2wR5jOxnhWqALgi19j+eUt6YwZB79iNQF+leE=
=eKIw
-----END PGP SIGNATURE-----

--J7enpp3EX8Cu2vSrxjSWFqMhN89rOenTJ--
