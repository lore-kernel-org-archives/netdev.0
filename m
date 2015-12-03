From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v4 net 0/6] Marvell Armada XP/370/38X Neta fixes
Date: Thu, 03 Dec 2015 14:43:05 +0100
Message-ID: <874mfz1wd2.fsf@free-electrons.com>
References: <1448886466-31538-1-git-send-email-mw@semihalf.com>
	<20151201.220337.2287051759324173025.davem@davemloft.net>
	<87wpsx2rll.fsf@free-electrons.com>
	<20151202.153152.345490122870853342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mw@semihalf.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, sebastian.hesselbarth@gmail.com,
	andrew@lunn.ch, jason@lakedaemon.net,
	thomas.petazzoni@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, jaz@semihalf.com,
	tn@semihalf.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151202.153152.345490122870853342.davem@davemloft.net> (David
	Miller's message of "Wed, 02 Dec 2015 15:31:52 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,
=20
 On mer., d=C3=A9c. 02 2015, David Miller <davem@davemloft.net> wrote:

> From: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Date: Wed, 02 Dec 2015 09:16:06 +0100
>
>> Hi David,
>> =20
>>  On mer., d=C3=A9c. 02 2015, David Miller <davem@davemloft.net> wrot=
e:
>>=20
>>> From: Marcin Wojtas <mw@semihalf.com>
>>> Date: Mon, 30 Nov 2015 13:27:40 +0100
>>>
>>>> I'm sending v4 with corrected commit log of the last patch, in ord=
er
>>>> to avoid possible conflicts between the branches as suggested by
>>>> Gregory Clement.
>>>
>>> Series applied, thanks.
>>=20
>> Could you confirm that you don't apply the last patch?
>
> If I say it's applied then it's applied, and if you don't like it the=
n
> you'll have to submit a revert patch against my tree or similar.
>
> You know you could just check my tree instead of asking.

Well I was very surprised that you applied a patch in a subsystem that
you do not maintain. As written on the lines just below yours, the
purpose of this v4 was to make clear that the last patch is not for the
net subsystem but for the arm/mvebu one.

As this series will be part of the next rc, then I hope we won't have
conflicts during next merge.

Gregory


--=20
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
