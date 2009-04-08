From: "Trenton D. Adams" <trenton.d.adams@gmail.com>
Subject: Re: 2.6.29 on MacBook 2,1 fails to reboot (was Re: 2.6.29-git13:
	Reported regressions from 2.6.28)
Date: Tue, 7 Apr 2009 19:16:08 -0600
Message-ID: <9b1675090904071816k59080f1fn39737767db4dc0c@mail.gmail.com>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>
	 <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>
	 <49DB7C77.1000702@s5r6.in-berlin.de>
	 <9b1675090904070944m798ed608i1d9194ebd1ed3961@mail.gmail.com>
	 <49DB8909.3000905@s5r6.in-berlin.de>
	 <9b1675090904071122k6a53295fwfffc336011edee8e@mail.gmail.com>
	 <49DBA821.1070408@s5r6.in-berlin.de>
	 <9b1675090904071352x513510ecm8b2574859b088275@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Takashi Iwai <tiwai@suse.de>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <9b1675090904071352x513510ecm8b2574859b088275@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 7, 2009 at 2:52 PM, Trenton D. Adams
<trenton.d.adams@gmail.com> wrote:
> On Tue, Apr 7, 2009 at 1:23 PM, Stefan Richter
> <stefanr@s5r6.in-berlin.de> wrote:
>>
>> But more importantly, is this init scripts related bug really what's
>> happening at your system? =A0Or do you actually experience an entire=
ly
>> different bug?
>
> It could be. =A0I will try it out when I get home from work, and get
> back to you. =A0That would be cool if it was a simple init script
> problem. =A0Cause then I don't have to do anymore git bisects. ;)

Yes, the order is what causes this, you can close the bug.

Sorry for wasting everyone's time.  I thought it was a kernel bug
because I had not needed to update my gentoo system to make it happen.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
