From: Dave Airlie <airlied@gmail.com>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Fri, 4 Feb 2011 10:45:19 +1000
Message-ID: <AANLkTi=RQZ4fN9rZQRhiza5Nd9LkBO=tO1AWjSstRjV1@mail.gmail.com>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera>
	<AANLkTikELiGS+fM5WguZS=Fo-sSXmej1UnKWqCFmnE0k@mail.gmail.com>
	<s5haaid3xos.wl%tiwai@suse.de>
	<201102032009.17100.rjw@sisk.pl>
	<AANLkTi=suS1VDL=6EtT0D2=0c1DWwxdwZBBv=-BySNX-@mail.gmail.com>
	<AANLkTi=7EOih=fY5FCvhQbewSc=3a49cYVaKJRWM+-3d@mail.gmail.com>
	<AANLkTin7kBur95H=UBcYEcjYsUkrdG8znX-7PFZ4rrHf@mail.gmail.com>
	<AANLkTimQPPDyBwkN0HWM2+bPcbzVd8YHZvn2iR8MVzfL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Carlos Mafra <crmafra2@gmail.com>,
	Keith Packard <keithp@keithp.com>,
	Dave Airlie <airlied@redhat.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Takashi Iwai <tiwai@suse.de>,
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
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:49464 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab1BDApU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 19:45:20 -0500
In-Reply-To: <AANLkTimQPPDyBwkN0HWM2+bPcbzVd8YHZvn2iR8MVzfL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 4, 2011 at 10:30 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, Feb 3, 2011 at 4:06 PM, Dave Airlie <airlied@gmail.com> wrote:
>>
>> If we are setting a mode on a connector it automatically will end up
>> in a DPMS on state,
>> so this seemed correct from what I can see.
>
> The more I look at that function, the more I disagree with you and
> with that patch.
>
> The code is just crazy.

Good point, I'm just trying to get -rc3 onto a machine where I can
reproduce this now, unfortunately that looks like the machine with the
1.8" disk, so this could take a little while.

hopefully Keith will decloak and tell us more.

Dave.
