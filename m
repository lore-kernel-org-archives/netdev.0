From: Matthias Heinz <mheinz@cs.uni-frankfurt.de>
Subject: Re: 2.6.29-rc1: Reported regressions from 2.6.28
Date: Sun, 11 Jan 2009 15:39:46 +0100
Message-ID: <200901111539.48098.mheinz@cs.uni-frankfurt.de>
References: <XU-8icArWLM.A.UpG.8GfaJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <XU-8icArWLM.A.UpG.8GfaJB@chimera>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag, 11. Januar 2009 schrieb Rafael J. Wysocki:
> If you know of any other unresolved regressions from 2.6.28, please l=
et me
> know either and I'll add them to the list. =C2=A0Also, please let me =
know if any
> of the entries below are invalid.

Unresolved regressions
----------------------

Bug-Entry=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0: http://bugzilla.ke=
rnel.org/show_bug.cgi?id=3D12174
Subject=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0: No backl=
ight control on Samsung x360

I think this is a common bug on systems with a broken(?) bios, exposing=
 wrong=20
driver names. With 2.6.27 it was at least possible to control the backl=
ight=20
over the NVID interface.
--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
