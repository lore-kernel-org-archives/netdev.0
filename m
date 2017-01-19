From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Thu, 19 Jan 2017 02:01:53 +0100
Message-ID: <15df4643-d553-fe73-4ced-2c963179d04b@digikod.net>
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
 <20170118224120.GG9171@mtj.duckdns.org>
 <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="L97IftgON9JN95xleTv0c32ASrTpqg1M3"
Cc: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--L97IftgON9JN95xleTv0c32ASrTpqg1M3
Content-Type: multipart/mixed; boundary="JuclDMBKoQwEAwqQc1hKQkS68vKW4FPL1";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
 David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
 Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
 Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Message-ID: <15df4643-d553-fe73-4ced-2c963179d04b-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <20170118224120.GG9171-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org>
 <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
In-Reply-To: <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>

--JuclDMBKoQwEAwqQc1hKQkS68vKW4FPL1
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 19/01/2017 01:18, Andy Lutomirski wrote:
>>> it explicitly respects the cgroup hierarchy.  It shows up in
>>> /proc/cgroups, and I had no problem mounting a cgroupfs instance with=

>>> perf_event enabled.  So I'm not sure what you mean.
>>
>> That all it's doing is providing membership information.
>=20
> But it's doing it wrong!  Even perf_event tests for membership in a
> given cgroup *or one of its descendents*.  This code does not.
>=20
> I think the moral of the story here is that there are lots of open
> questions and design work to be done and that this feature really
> isn't ready to be stable.  For Landlock, I believe that it really
> needs to be done right and I will put my foot down and NAK any effort
> to have Landlock available in a released kernel without resolving
> these types of issues first.  Does anyone really want Landlock to work
> differently than the net hooks simply because the net hooks were in a
> rush?

About Landlock, there is two use cases:

The first is to allow unprivileged users to tie eBPF programs (rules) to
processes. This is the (final) goal. In this case, a (cgroup) hierarchy
is mandatory, otherwise it would be trivial to defeat any access rule.
This is the same issue with namespaces.

The second use case is to only allow privileged users to tie eBPF
programs to processes. As discussed, this will be the next series,
preceding the unprivileged series. In this privilege case, only root
(global CAP_SYS_ADMIN, no namespaces) may be able to use Landlock. Not
having a hierarchy is not a security issue (only a practical one).

The first/next Landlock series (in February) will focus on process
hierarchies (without cgroup), a la seccomp-bpf. It would be too
confusing to not use an inheritable hierarchy like seccomp does, even in
a privileged-only first approach. The inherited rules should then behave
similarly to the seccomp-bpf filters.

However, the following series focusing on cgroup could keep the current
cgroup-bpf behavior, without hierarchy. I don't like the non-hierarchy
approach very much because it add another (less flexible and more
confusing) way to do things (for Landlock at least), but I'm willing to
do it if needed.

Regards,
 Micka=C3=ABl


--JuclDMBKoQwEAwqQc1hKQkS68vKW4FPL1--

--L97IftgON9JN95xleTv0c32ASrTpqg1M3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAliAEAEACgkQIt7+33O9
apXLUwf/TLqkj3fjbNfx/z2AAlEUe+AYES16PvY4VeCq1Cmz+9KFYXDVUyyLpRNr
F9n8QTEG7PXnbEMTR6PkSUy7HMhVbGr2le4bKvytnsQnMuvd9iObDth75PdrP7em
Z+gNW1mQ/s0j19+U9BqdA/cZnmt1AKmU4ToVjpLNd/+YIOxwASrBNWj616pRb4mI
CIdsF12XW0J026LQ+6ccS3E2k2AkOFl6rPzEFn1DyFf3QlxkKjL/GCFOd03v050t
yRD8e6ZQZT8XGyjec2i8X+mbkM0zAMWJEdhM5MxEX8Jymw8PdbM+W/E2wzL6Fwkb
gXiNzJyJfwMpEokyg5MF/FOgyBBqVQ==
=zb0o
-----END PGP SIGNATURE-----

--L97IftgON9JN95xleTv0c32ASrTpqg1M3--
