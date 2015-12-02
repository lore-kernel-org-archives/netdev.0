From: Tom Herbert <tom@herbertland.com>
Subject: Re: ipsec impact on performance
Date: Wed, 2 Dec 2015 14:01:43 -0800
Message-ID: <CALx6S34bCaL1PRfFgiPuj8d7m6EvbfzebtAHpN=QkKMuTgO9Fw@mail.gmail.com>
References: <20151201175953.GC21252@oracle.com>
	<CALx6S35uLqbuJTAFLMeT-BcyZw_fksz+7BkS=Nt7_3-nYMHF2A@mail.gmail.com>
	<20151201183720.GE21252@oracle.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
	<20151202121156.GK23178@oracle.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CBE0F39@AcuExch.aculab.com>
	<20151202205028.GB15262@oracle.com>
	<CALx6S34yqw_vJ+r21Br9O7y5NqzvA264ot7=GBTHe=FxWqh=AQ@mail.gmail.com>
	<20151202211201.GD15262@oracle.com>
	<CALx6S36gcbJRJOTdUhgZGVbe4YzBeuBgv105kXLMyDSBBQ_56Q@mail.gmail.com>
	<20151202214708.GF15262@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	Rick Jones <rick.jones2@hpe.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20151202214708.GF15262@oracle.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 2, 2015 at 1:47 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (12/02/15 13:44), Tom Herbert wrote:
>> > IPv6 would be an interesting academic exercise, but it's going
>> > to be a while before we get RDS-TCP to go over IPv6.
>> >
>> Huh? Who said anything about RDS-TCP? I thought you were trying to
>> improve IPsec performance...
>
> yes, and it would be nice to find out that IPsec for IPv6 is
> fast, but I'm afraid there are a lot of IPv4 use cases out there that
> need the same thing for IPv4 too (first?).
>
No, please don't persist is this myopic "we'll get to IPv6 later"
model! IPv6 is a real protocol, it has significant deployment of the
Internet, and there are now whole data centers that are IPv6 only
(e.g. FB), and there are plenty of use cases of IPSEC/IPv6 that could
benefit for performance improvements just as much IPv4. This vendor
mentality that IPv6 is still not important simply doesn't help
matters. :-(

Tom
