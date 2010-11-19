From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.37-rc2-git4: Reported regressions 2.6.35 -> 2.6.36
Date: Thu, 18 Nov 2010 16:36:54 -0800
Message-ID: <AANLkTinzHyWcfS++R_d+yqR9JQu7W51h0XRr-ikd_6y1@mail.gmail.com>
References: <tTUH_XeInOH.A.dMF.c3b5MB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <tTUH_XeInOH.A.dMF.c3b5MB@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 18, 2010 at 3:50 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D=
20462
> Subject =A0 =A0 =A0 =A0 : 2.6.36-rc7-git2 - panic/GPF: e1000e/vlans?
> Submitter =A0 =A0 =A0 : Nikola Ciprich <extmaillist@linuxbox.cz>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-10-15 7:10 (35 days old)
> Message-ID =A0 =A0 =A0: <20101015071008.GA8714@pcnci.linuxbox.cz>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D128712=
984831303&w=3D2

A fix for this has been sent to -stable:
http://www.spinics.net/lists/netdev/msg146227.html
