From: "Trenton D. Adams" <trenton.d.adams-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.29-git13: Reported regressions from 2.6.28
Date: Tue, 7 Apr 2009 10:44:37 -0600
Message-ID: <9b1675090904070944m798ed608i1d9194ebd1ed3961@mail.gmail.com>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>
	 <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>
	 <49DB7C77.1000702@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49DB7C77.1000702-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 7, 2009 at 10:16 AM, Stefan Richter
<stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org> wrote:
> Linus Torvalds wrote:
>> On Mon, 6 Apr 2009, Rafael J. Wysocki wrote:
>>> Bug-Entry =A0 =A0: http://bugzilla.kernel.org/show_bug.cgi?id=3D130=
18
>>> Subject =A0 =A0 =A0 =A0 =A0 =A0 =A0: 2.6.29 on MacBook 2,1 fails to=
 reboot
>>> Submitter =A0 =A0: Trenton Adams <trenton.d.adams-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> Date =A0 =A0 =A0 =A0 : 2009-03-30 2:04 (8 days old)
>>> References =A0 : http://marc.info/?l=3Dlinux-kernel&m=3D12383787030=
7249&w=3D4
>>> Handled-By =A0 : "Morten P.D. Stevens" <mstevens@win-professional.c=
om>
>>
>
> Trenton,
> could it be the same as this one?
> http://bugzilla.kernel.org/show_bug.cgi?id=3D12321
> "System hangs when unloading alsa modules"
> http://bugs.gentoo.org/show_bug.cgi?id=3D253535
> "System hangs when unloading alsa modules on Kernel >2.6.28"
> --
> Stefan Richter
> -=3D=3D=3D=3D=3D-=3D=3D--=3D -=3D-- --=3D=3D=3D
> http://arcgraph.de/sr/
>

The first one looks similar, if not identical.  The second one
doesn't, because my problem happens on 2.6.29 only, not 2.6.28.
Either way, the unload problem with the module didn't happen in
2.6.28.
