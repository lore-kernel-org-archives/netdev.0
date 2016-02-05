From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH] net: ethernet: support "fixed-link" DT node on nb8800 driver
Date: Fri, 05 Feb 2016 15:58:42 +0000
Message-ID: <yw1x7fijgnd9.fsf@unicorn.mansr.com>
References: <56B4A445.7080402@laposte.net>
	<yw1x1t8ri8dz.fsf@unicorn.mansr.com>
	<CAHp75Vc0nW5EuLD7-ZmB5e63vvFLdmjfbd4a1nAweeTGOs795Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian Frias <sf84@laposte.net>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75Vc0nW5EuLD7-ZmB5e63vvFLdmjfbd4a1nAweeTGOs795Q@mail.gmail.com>
	(Andy Shevchenko's message of "Fri, 5 Feb 2016 17:57:56 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Shevchenko <andy.shevchenko@gmail.com> writes:

> On Fri, Feb 5, 2016 at 3:39 PM, M=E5ns Rullg=E5rd <mans@mansr.com> wr=
ote:
>>> +                     if (ret < 0) {
>>> +                             dev_err(&pdev->dev, "broken fixed-lin=
k specification\n");
>>
>> Line is longer than 80 chars.
>
> This is actually okay, though I would recommend to move long string
> literal to the next line.

I only mentioned it because fixing it was trivial.

--=20
M=E5ns Rullg=E5rd
