From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH net-next] drivers/net/bfin_mac.c: Use
	pr_fmt, netdev_<level>
Date: Wed, 28 Jul 2010 11:36:35 -0400
Message-ID: <AANLkTimHYS8BRBbomxwyqwayu8eyp+k6TurtsniNTMfs@mail.gmail.com>
References: <1280258531.24054.10.camel@Joe-Laptop.home> <AANLkTi=p=-ovBaqyqBdEW=W4E1ArWsiyUBwy37GtXOyu@mail.gmail.com>
	<1280311240.24054.103.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Hennerich <michael.hennerich@analog.com>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1280311240.24054.103.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 28, 2010 at 06:00, Joe Perches wrote:
> On Wed, 2010-07-28 at 03:50 -0400, Mike Frysinger wrote:
>> On Tue, Jul 27, 2010 at 15:22, Joe Perches wrote:
>> > $ ./scripts/checkpatch.pl -f drivers/net/bfin_mac.c | grep "^total=
:"
>> > total: 2 errors, 25 warnings, 1723 lines checked
>> > $ ./scripts/checkpatch.pl -f drivers/net/bfin_mac.c | grep "^total=
:"
>> > total: 0 errors, 0 warnings, 1743 lines checked
>> i dislike the mixing of whitespace and useful changes
>> if they were split, and they worked, then i wouldnt have a problem w=
ith them
>
> Is that a nak or a dislike?

if you arent going to bother fixing things, then i guess it's a NAK ;)

> Also, is Michael Hennerich actually the maintainer for bfin_mac?
> He had been =C2=A0listed as MAINTAINER for over a year but he hasn't
> ever written or acked a patch for this file.

i dont know what log you're reading, but i see Michael making plenty
of changes to this driver
-mike
