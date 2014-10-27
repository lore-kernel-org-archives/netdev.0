From: Roberto Medina <robertoxmed@gmail.com>
Subject: Re: [PATCH] net: ethernet: realtek: atp: checkpatch errors and warnings
 corrected
Date: Tue, 28 Oct 2014 00:04:36 +0100
Message-ID: <544ECF84.80208@gmail.com>
References: <1414084200-5377-1-git-send-email-robertoxmed@gmail.com>	<20141027.185211.1433818002293610983.davem@davemloft.net> <20141027.185355.1412632964802440855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141027.185355.1412632964802440855.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/2014 11:53 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 27 Oct 2014 18:52:11 -0400 (EDT)
>
>> From: Roberto Medina <robertoxmed@gmail.com>
>> Date: Thu, 23 Oct 2014 19:10:00 +0200
>>
>>> From: Roberto Medina <robertoxmed@gmail.com>
>>>
>>> Several warnings and errors of coding style errors corrected.
>>>
>>> Signed-off-by: Roberto Medina <robertoxmed@gmail.com>
>>
>> Applied, thanks.
>
> Wait, are you serious, you didn't even compile test this change?
>
> For real?
>
> In file included from drivers/net/ethernet/realtek/atp.c:146:0:
> drivers/net/ethernet/realtek/atp.h:79:15: error: expected =A1;=A2, id=
entifier or =A1(=A2 before =A1unsigned=A2
>   static inline unsigned char inbyte(unsigned short port)
>                 ^
> drivers/net/ethernet/realtek/atp.h:79:15: error: =A1inline=A2 in empt=
y declaration
>

Wow I'm really sorry for that, I did compile my changes, or at least=20
that's what I thought when I compiled the directory.

Will submit another patch. Sorry for the inconvenience again.

> Don't even submit changes meant for inclusion if you're not even
> willing to build test them.
>
> And I'm very serious about this.
>
