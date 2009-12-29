From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.33-rc2: Reported regressions 2.6.31 -> 2.6.32
Date: Tue, 29 Dec 2009 23:00:51 +0100
Message-ID: <20091229220051.GA3185@del.dom.local>
References: <oBElxfTZdhL.A.bx.-vhOLB@chimera>
 <4B3A5BC2.10207@gmail.com>
 <4B3A6CB1.3030305@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: =?iso-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:58387 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471AbZL2WA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 17:00:59 -0500
Content-Disposition: inline
In-Reply-To: <4B3A6CB1.3030305@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2009 at 09:55:13PM +0100, N=E9meth M=E1rton wrote:
> Jarek Poplawski wrote:
> > Rafael J. Wysocki wrote, On 12/29/2009 04:26 PM:
> >=20
> > ...
> >> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14794
> >> Subject		: IP address assigned by DHCP is dropped after ~40 second=
s
> >> Submitter	: M=E1rton N=E9meth <nm127@freemail.hu>
> >> Date		: 2009-12-13 08:59 (17 days old)
> >>
> >=20
> >=20
> > IMHO this bug might be considered as fixed by updating a userspace =
tool
> > (KNetworkManager) - unless somebody wants to seek for the exact rea=
son...
>=20
> For me (I am the reporter) the problem was solved by upgrading a user=
space
> tool, so I think the bug filed against the kernel can be closed marki=
ng
> that this was not really a kernel bug.

Yes, let's hope author(s) of KNetworkManager would let us know if they
had to change it because of the kernel error.

Regards,
Jarek P.
