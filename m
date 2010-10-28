From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: fix crash due to manipulating queues before
 registration
Date: Thu, 28 Oct 2010 10:28:13 -0700 (PDT)
Message-ID: <20101028.102813.59675147.davem@davemloft.net>
References: <1288242390-28574-1-git-send-email-nacc@us.ibm.com>
	<1288243110.2658.126.camel@edumazet-laptop>
	<20101028052349.GA21144@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, sonnyrao@us.ibm.com, divy@chelsio.com,
	dm@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nacc@us.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101028052349.GA21144@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Wed, 27 Oct 2010 22:23:49 -0700

> On 28.10.2010 [07:18:30 +0200], Eric Dumazet wrote:
>> Le mercredi 27 octobre 2010 =E0 22:06 -0700, Nishanth Aravamudan a =E9=
crit :
>> > Hi Eric,
>> >=20
>> > Something like the following?:
>> >=20
>> > Thanks,
>> > Nish
>>=20
>> Yes, probably, but I dont have the hardware so cannot test.
>=20
> Sorry, should have been clearer. I do have the hardware, tested with =
the
> patch, it does work. Wanted to make sure that it made sense to the
> maintainers, of course, but:
>=20
> Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>

Applied, thank you.
