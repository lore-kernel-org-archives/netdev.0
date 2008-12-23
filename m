From: Wide Link PC <infos@widelinkpc.be>
Subject: Re: [Bugme-new] [Bug 12228] New: D-Link 530 TX Rev. C2 not working
Date: Tue, 23 Dec 2008 08:46:19 +0100
Message-ID: <4950974B.9000207@widelinkpc.be>
References: <bug-12228-10286@http.bugzilla.kernel.org/> <20081215001816.79f1332b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.nuxit.net ([195.114.18.69]:42115 "EHLO smtp3.nuxit.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332AbYLWHx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2008 02:53:26 -0500
In-Reply-To: <20081215001816.79f1332b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good morning,

Ahah, Santa Claus is in the place !!! Fixed with the last kernel update=
=20
of Ubuntu 8.10.
I was right, it was from kernel.

Thanks for your answer.

Merry Chrismas and happy new year 2009.

Oliver.

Andrew Morton a =E9crit :
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>
> On Mon, 15 Dec 2008 00:00:56 -0800 (PST) bugme-daemon@bugzilla.kernel=
=2Eorg wrote:
>
>  =20
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D12228
>>
>>            Summary: D-Link 530 TX Rev. C2 not working
>>            Product: Drivers
>>            Version: 2.5
>>      KernelVersion: 2.6.27.X
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: jgarzik@pobox.com
>>         ReportedBy: infos@widelinkpc.be
>>
>>
>> Latest working kernel version: 2.6.24 and 2.6.25
>> Earliest failing kernel version: 2.6.27.X
>> Distribution: Actually Ubuntu 8.10 Deskstop (32 bit) and Fedora 10 D=
eskstop (32
>> bit)
>> Hardware Environment: Always the same since many years to test diffe=
rent
>> distributions: Asus P4P800 SE, GeForce 7800 GS in AGP, 2 x 1 GB DDR =
1 Kingmax.
>> Software Environment: just TeamSpeak Server on Ubuntu 8.10 and CCSM =
(Compiz
>> Configurator). Fedora nothing more than original package. Just updat=
e from
>> Fedora repositories.
>> Problem Description: in the past this hardware working fine with pre=
vious
>> version of distribution. Since the last version, my nertwork card do=
esn't work.
>> I'm not a hacker, just want help you.
>>
>> Steps to reproduce: I have tested 2 distributions with install on my=
 hardrive.
>> Not working. I change hardrive to see on Windows (whith drivers of c=
ourse) and
>> my card working fine. The hardware working fine, but I think there i=
s a problem
>> with Linux driver. I haven't problem to connect internet with the on=
board chip
>> Marvell Yukon.
>>
>> I hope it's not a bug from Network Manager, but I think no.
>>
>>    =20
>
> ok, I give up ;)  Which device driver does that card use?
>
>
> __________ Information from ESET NOD32 Antivirus, version of virus si=
gnature database 3691 (20081214) __________
>
> The message was checked by ESET NOD32 Antivirus.
>
> http://www.eset.com
>
>
>
>
>  =20
