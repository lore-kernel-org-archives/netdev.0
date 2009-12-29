From: =?UTF-8?B?TsOpbWV0aCBNw6FydG9u?= <nm127@freemail.hu>
Subject: Re: 2.6.33-rc2: Reported regressions 2.6.31 -> 2.6.32
Date: Tue, 29 Dec 2009 21:55:13 +0100
Message-ID: <4B3A6CB1.3030305@freemail.hu>
References: <oBElxfTZdhL.A.bx.-vhOLB@chimera> <4B3A5BC2.10207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01d.mail.t-online.hu ([84.2.42.6]:64791 "EHLO
	mail01d.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbZL2UzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 15:55:23 -0500
In-Reply-To: <4B3A5BC2.10207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Rafael J. Wysocki wrote, On 12/29/2009 04:26 PM:
>=20
> ...
>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14794
>> Subject		: IP address assigned by DHCP is dropped after ~40 seconds
>> Submitter	: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>
>> Date		: 2009-12-13 08:59 (17 days old)
>>
>=20
>=20
> IMHO this bug might be considered as fixed by updating a userspace to=
ol
> (KNetworkManager) - unless somebody wants to seek for the exact reaso=
n...

=46or me (I am the reporter) the problem was solved by upgrading a user=
space
tool, so I think the bug filed against the kernel can be closed marking
that this was not really a kernel bug.

Regards,

	M=C3=A1rton N=C3=A9meth


