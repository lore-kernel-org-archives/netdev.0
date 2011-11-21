From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Mon, 21 Nov 2011 14:20:35 -0800
Message-ID: <CA+55aFyceMKgS-YRv=r=FrHQ1P9=z7=2PC5gvZcCHoYKnzn_Aw@mail.gmail.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <201111212249.31196.rjw@sisk.pl>
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
To: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Ari Savolainen <ari.m.savolainen@gmail.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <201111212249.31196.rjw@sisk.pl>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 21, 2011 at 1:49 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>
> Subject =A0 =A0: lockdep warning after aa6afca5bcab: "proc: fix races=
 against execve() of /proc/PID/fd**"
> Submitter =A0: Ari Savolainen <ari.m.savolainen@gmail.com>
> Date =A0 =A0 =A0 : 2011-11-08 3:47
> Message-ID : CAEbykaXYZEFhTgWMm2AfaWQ2SaXYuO_ypTnw+6AVWScOYSCuuw@mail=
=2Egmail.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132072413125099&w=
=3D2

Commit aa6afca5bcab was reverted by commit 5e442a493fc5, so this one
is presumably stale.

                      Linus
--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
