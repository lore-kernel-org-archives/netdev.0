From: Carlos Mafra <crmafra2@gmail.com>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Thu, 3 Feb 2011 22:56:29 +0100
Message-ID: <AANLkTi=suS1VDL=6EtT0D2=0c1DWwxdwZBBv=-BySNX-@mail.gmail.com>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera>
	<AANLkTikELiGS+fM5WguZS=Fo-sSXmej1UnKWqCFmnE0k@mail.gmail.com>
	<s5haaid3xos.wl%tiwai@suse.de>
	<201102032009.17100.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Takashi Iwai <tiwai@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Keith Packard <keithp@keithp.com>,
	Dave Airlie <airlied@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <201102032009.17100.rjw@sisk.pl>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 3, 2011 at 8:09 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Thursday, February 03, 2011, Takashi Iwai wrote:
>> At Thu, 3 Feb 2011 07:42:05 -0800,
>> Linus Torvalds wrote:
>> >
>> > On Thu, Feb 3, 2011 at 3:23 AM, Carlos R. Mafra <crmafra2@gmail.co=
m> wrote:
>> > > On Thu =A03.Feb'11 at =A01:03:41 +0100, Rafael J. Wysocki wrote:

>> > Just to confirm, can you also check -rc3? I'm pretty sure nothing =
has
>> > changed, but there were a few drm patches after -rc2, so it's alsw=
ays
>> > good to double-check.
>>
>> The problem I reported in the bugzilla above is still present in
>> 2.6.38-rc3. =A0I'm pretty sure that's the same issue as Carlos' case=
=2E
>
> I added https://bugzilla.kernel.org/show_bug.cgi?id=3D24982 to the li=
st of
> post-2.6.36 regressions for further tracking.

I also tested on 2.6.38-rc3+ now and the issue is not solved,
just like Takashi expected.
--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
