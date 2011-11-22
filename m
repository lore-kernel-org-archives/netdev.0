From: Ari Savolainen <ari.m.savolainen@gmail.com>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Tue, 22 Nov 2011 07:27:03 +0200
Message-ID: <CAEbykaWN_PMQh_KJEhO0XQZwcUoOad8bugruX+9NbGszVp=2Hw@mail.gmail.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera>
	<201111212249.31196.rjw@sisk.pl>
	<CA+55aFyceMKgS-YRv=r=FrHQ1P9=z7=2PC5gvZcCHoYKnzn_Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
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
To: Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:53362 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab1KVF1G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 00:27:06 -0500
In-Reply-To: <CA+55aFyceMKgS-YRv=r=FrHQ1P9=z7=2PC5gvZcCHoYKnzn_Aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/22 Linus Torvalds <torvalds@linux-foundation.org>:
> On Mon, Nov 21, 2011 at 1:49 PM, Rafael J. Wysocki <rjw@sisk.pl> wrot=
e:
>>
>> Subject =A0 =A0: lockdep warning after aa6afca5bcab: "proc: fix race=
s against execve() of /proc/PID/fd**"
>> Submitter =A0: Ari Savolainen <ari.m.savolainen@gmail.com>
>> Date =A0 =A0 =A0 : 2011-11-08 3:47
>> Message-ID : CAEbykaXYZEFhTgWMm2AfaWQ2SaXYuO_ypTnw+6AVWScOYSCuuw@mai=
l.gmail.com
>> References : http://marc.info/?l=3Dlinux-kernel&m=3D132072413125099&=
w=3D2
>
> Commit aa6afca5bcab was reverted by commit 5e442a493fc5, so this one
> is presumably stale.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Linus

Yes, this went away after the reversion.

Ari
