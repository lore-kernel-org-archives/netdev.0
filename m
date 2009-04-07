From: "Trenton D. Adams" <trenton.d.adams@gmail.com>
Subject: Re: 2.6.29-git13: Reported regressions from 2.6.28
Date: Mon, 6 Apr 2009 21:56:27 -0600
Message-ID: <9b1675090904062056v235af58ehc99cce8ff97fe501@mail.gmail.com>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>
	 <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 6, 2009 at 3:53 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>
> On Mon, 6 Apr 2009, Rafael J. Wysocki wrote:
>>
>> Bug-Entry =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D130=
18
>> Subject =A0 =A0 =A0 =A0 =A0 =A0 =A0 : 2.6.29 on MacBook 2,1 fails to=
 reboot
>> Submitter =A0 =A0 : Trenton Adams <trenton.d.adams@gmail.com>
>> Date =A0 =A0 =A0 =A0 =A0: 2009-03-30 2:04 (8 days old)
>> References =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D123837870=
307249&w=3D4
>> Handled-By =A0 =A0: "Morten P.D. Stevens" <mstevens@win-professional=
=2Ecom>
>
> This went through bisection, but looking at the email log, I tend to
> suspect that maybe Trenton marked some versions good even though they
> weren't (because they got versions numbers from v2.6.27), and didn't
> realize that that messes up bisection in a big way.

Is it appropriate for me to respond to these things?

I was wondering about that.  Someone had mentioned that I should trust
the bisect, even when it takes me into "other versions", and it was
taking me through 2.6.27, which I thought was just really weird.
Would you like me to try the bisect again with a little more
diligence, or do you think it can be found with the info given?  It
may take a week or so, due to being a bit busy.

Thanks
--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
