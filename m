From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 14 Jan 2011 14:44:03 +0800
Message-ID: <AANLkTimsY88hD8HkBvMMTT2cs7vec2p8yUBNfeKsHod2@mail.gmail.com>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
 <1294928559.3570.130.camel@edumazet-laptop> <20110113082950.6747ebb8@queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Andres Salomon <dilinger@queued.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110113082950.6747ebb8@queued.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Andres,

On Fri, Jan 14, 2011 at 12:29 AM, Andres Salomon <dilinger@queued.net> =
wrote:
> On Thu, 13 Jan 2011 15:22:39 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Le jeudi 13 janvier 2011 =C3=A0 19:49 +0800, Po-Yu Chuang a =C3=A9cr=
it :

> No one else mentioned it, so I'll add:
>
> Don't explicitly inline functions unless they're in a header, or you
> have a really good reason (and that reason should probably be describ=
ed
> in a comment). =C2=A0Otherwise, just leave off the 'inline' keyword; =
the
> compiler is smart enough to decide whether a function should be inlin=
ed
> or not.

OK, fixed.

Thanks,
Po-Yu Chuang
