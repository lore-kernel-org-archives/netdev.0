From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Tue, 01 Mar 2011 06:26:44 +0100
Message-ID: <1298957204.2676.4.camel@edumazet-laptop>
References: <1298539762-2242-1-git-send-email-ratbert.chuang@gmail.com>
	 <1298627845-1583-1-git-send-email-ratbert.chuang@gmail.com>
	 <1298634040.2659.32.camel@edumazet-laptop>
	 <AANLkTimeDR27Q7fcBmB0ix7Q_pRT_GDpc7S3LO21-fh-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, davem@davemloft.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimeDR27Q7fcBmB0ix7Q_pRT_GDpc7S3LO21-fh-@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 01 mars 2011 =C3=A0 13:20 +0800, Po-Yu Chuang a =C3=A9crit :
> Hi Eric,
>=20
> On Fri, Feb 25, 2011 at 7:40 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:

> Both NIU and BENET refill rx ring after all packets receive work done=
,
> but I allocate rx buffer right after a packet is received. I think it
> is difficult
> to use a page for two rx buffers in my driver now. Can we just keep i=
t
> the way it is? I can study how to achieve that after current driver i=
s accepted.
>=20

No problem, you are the author, I am only a reviewer and ask questions
after all ;)

Thanks !
