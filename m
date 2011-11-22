From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Mon, 21 Nov 2011 23:16:25 -0800
Message-ID: <CALCETrXP63VYU6mvxuUJKq7uJ-a3LG6c4t6asQFGUsJnrP6_ow@mail.gmail.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <201111212249.31196.rjw@sisk.pl>
 <CA+55aFwAELQieN=qR7Gz_MT5rHPp90H10uTMS+DOJjefk7q3ng@mail.gmail.com> <CALCETrUpXrsjBLZsZU3u+y7KCDO0LW55QoBQkBqN_BPFZHsrkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrUpXrsjBLZsZU3u+y7KCDO0LW55QoBQkBqN_BPFZHsrkw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 21, 2011 at 2:34 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> =
wrote:
> On Mon, Nov 21, 2011 at 2:11 PM, Linus Torvalds
> <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>> On Mon, Nov 21, 2011 at 1:49 PM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wro=
te:
>>>
>>> Subject =A0 =A0: [3.1 REGRESSION] Commit 5cec93c216db77c45f7ce970d4=
6283bcb1933884 breaks the Chromium seccomp sandbox
>>> Submitter =A0: Nix <nix-dKoSMcxRz+Te9xe1eoZjHA@public.gmane.org>
>>> Date =A0 =A0 =A0 : 2011-11-14 0:40
>>> Message-ID : 8762inleno.fsf-AdTWujXS48Mg67Zj9sPl2A@public.gmane.org
>>> References : http://marc.info/?l=3Dlinux-kernel&m=3D132123396226377=
&w=3D2
>>

This is apparently fixed in seccompsandbox.  See:

https://code.google.com/p/seccompsandbox/issues/detail?id=3D17
https://code.google.com/p/seccompsandbox/source/detail?r=3D178

Unless someone objects, I'll consider this to not be a kernel
regression worth fixing.

--Andy
