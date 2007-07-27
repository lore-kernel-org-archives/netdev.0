From: Clemens Koller <clemens.koller@anagramm.de>
Subject: Re: D-Link DFE-580TX 4 port NIC problems
Date: Fri, 27 Jul 2007 14:08:09 +0200
Message-ID: <46A9E029.4080200@anagramm.de>
References: <20070509120142.2305a1d1@snibbles.dedenet.de>	<20070509032700.569789a0.akpm@linux-foundation.org> <20070727113044.76630826@snibbles.dedenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mario Doering <mario@dedenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.174]:55114 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759563AbXG0MIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 08:08:15 -0400
In-Reply-To: <20070727113044.76630826@snibbles.dedenet.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Mario!

Mario Doering schrieb:
> Hello,
>=20
> are there any news or questions on this issue?

Can you try the latest kernel to see if the same problem
persists?
Is there any kernel version where it was working fine?

> On Wed, 9 May 2007 03:27:00 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
>=20
>> On Wed, 9 May 2007 12:01:42 +0200 Mario Doering <mario@dedenet.de>
>> wrote:
>>
>>> Hello,
>>>
>>> we have a D-Link DFE-580TX 4 port network card in our main router.
>>>
>>> It works pretty well most of the time, even though an error
>>> message pops up in dmesg every now and then (sometimes once a day
>>> sometimes once every few hours).
>>>
>>>
>>> But every few weeks those error messages increase rapidly, spamming
>>> dmesg. When this happens the system does not react anymore and
>>> pushing the reset button is the only option left.
>>>
>>> I googled around and found out that other users have same problem,
>>> but no solution to this.
>>>
>>>
>>> Part of the message log is located here:
>>> http://test.dedenet.de/messages.gz
>>> or
>>> http://test.dedenet.de/messages.txt
>>>
>>>
>>> uname -a
>>> Linux router1 2.6.19-gentoo-r5 #1 Sat Feb 17 17:04:03 CET 2007 i686
>>> AMD Athlon(tm) XP AuthenticAMD GNU/Linux
>>>
>>>
>>> driver:
>>> [   17.364707] sundance.c:v1.2 11-Sep-2006  Written by Donald Becke=
r
>>> [   17.364711]   http://www.scyld.com/network/sundance.html
>>> [   17.364844] ACPI: PCI Interrupt 0000:03:04.0[A] -> GSI 17 (level=
,
>>> low) -> IRQ 17 [   17.365396] eth1: D-Link DFE-580TX 4 port Server
>>> Adapter at 0001bc00, 00:0d:88:cc:a5:f0, IRQ 17. [   17.366350] eth1=
:
>>> MII PHY found at address 1, status 0x7829 advertising 01e1.
>>> [   17.676491] ACPI: PCI Interrupt 0000:03:05.0[A] -> GSI 18 (level=
,
>>> low) -> IRQ 18 [   17.676912] eth2: D-Link DFE-580TX 4 port Server
>>> Adapter at 0001b800, 00:0d:88:cc:a5:f1, IRQ 18. [   17.677864] eth2=
:
>>> MII PHY found at address 1, status 0x7809 advertising 01e1.
>>> [   17.987730] ACPI: PCI Interrupt 0000:03:06.0[A] -> GSI 19 (level=
,
>>> low) -> IRQ 16 [   17.988107] eth3: D-Link DFE-580TX 4 port Server
>>> Adapter at 0001b400, 00:0d:88:cc:a5:f2, IRQ 16. [   17.989059] eth3=
:
>>> MII PHY found at address 1, status 0x7829 advertising 01e1.
>>> [   18.298910] ACPI: PCI Interrupt 0000:03:07.0[A] -> GSI 16 (level=
,
>>> low) -> IRQ 19 [   18.299320] eth4: D-Link DFE-580TX 4 port Server
>>> Adapter at 0001b000, 00:0d:88:cc:a5:f3, IRQ 19. [   18.300272] eth4=
:
>>> MII PHY found at address 1, status 0x7809 advertising 01e1.
>>>
>>>
>>> No such error message appears for about 7-10 days after a reboot.
>>> Maybe there is some kind of buffer running full?
>>>
>>> Do you need any additional info?
>>>
>>> Please CC me :-)
>> (cc netdev)


Regards,
--=20
Clemens Koller
__________________________________
R&D Imaging Devices
Anagramm GmbH
Rupert-Mayer-Stra=DFe 45/1
Linhof Werksgel=E4nde
D-81379 M=FCnchen
Tel.089-741518-50
=46ax 089-741518-19
http://www.anagramm-technology.com
