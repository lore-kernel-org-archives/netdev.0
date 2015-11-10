From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Tue, 10 Nov 2015 20:53:19 +0000
Message-ID: <yw1xziylpoe8.fsf@unicorn.mansr.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<1447178145.17135.75.camel@edumazet-glaptop2.roam.corp.google.com>
	<yw1xr3jxraqs.fsf@unicorn.mansr.com>
	<20151110.150403.1195107307226924000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151110.150403.1195107307226924000.davem@davemloft.net> (David
	Miller's message of "Tue, 10 Nov 2015 15:04:03 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: M=E5ns Rullg=E5rd <mans@mansr.com>
> Date: Tue, 10 Nov 2015 18:05:15 +0000
>
>> Because I haven't been following the netdev list closely for the las=
t
>> five years, and no documentation I read mentioned this function.  I =
can
>> certainly change it.
>
> It is always advisable to mimick what other drivers do and use them a=
s
> a reference, rather than depend upon documentation which by definitio=
n
> is always going to be out of sync with the source tree.

Sure.  The trick is to pick the right driver(s) to use as reference.
Quite a few of them don't use that function.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
