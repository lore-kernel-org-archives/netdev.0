From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 11:02:00 -0700
Message-ID: <46F16418.3070706@redhat.com>
References: <46F13E8B.4050309@redhat.com> <p73sl5aveqh.fsf@bingen.suse.de> <46F15305.2030507@redhat.com> <20070919172653.GB18045@one.firstfloor.org> <46F1608E.7060908@redhat.com> <20070919175700.GC18045@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761736AbXISSCd@vger.kernel.org>
In-Reply-To: <20070919175700.GC18045@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andi Kleen wrote:
> Spec doesn't match traditional behaviour then.

Well, determining whether that's the case is part of this exercise.


> IPv4 0.0.0.0 is=20
> traditionally an synonym for old style all broadcast (255.255.255.255=
)=20
> on UDP/RAW and it's certainly possible to connect() to that.=20

Where do you get this from?  And where is this implemented?  I don't
doubt it but I have to convince people to change the standard and
possibly introduce incompatibility.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFG8WQY2ijCOnn/RHQRAlsBAJ9qZRZXNN2VEy136MFIT1daHfju5ACdGiIW
k0I5e2BGRjvjbJrrAwtehqo=3D
=3DfX+i
-----END PGP SIGNATURE-----
