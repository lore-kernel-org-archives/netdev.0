From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] net: ethernet: support "fixed-link" DT node on nb8800 driver
Date: Fri, 5 Feb 2016 17:57:56 +0200
Message-ID: <CAHp75Vc0nW5EuLD7-ZmB5e63vvFLdmjfbd4a1nAweeTGOs795Q@mail.gmail.com>
References: <56B4A445.7080402@laposte.net>
	<yw1x1t8ri8dz.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian Frias <sf84@laposte.net>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1x1t8ri8dz.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 5, 2016 at 3:39 PM, M=C3=A5ns Rullg=C3=A5rd <mans@mansr.com=
> wrote:
>> +                     if (ret < 0) {
>> +                             dev_err(&pdev->dev, "broken fixed-link=
 specification\n");
>
> Line is longer than 80 chars.

This is actually okay, though I would recommend to move long string
literal to the next line.

--=20
With Best Regards,
Andy Shevchenko
