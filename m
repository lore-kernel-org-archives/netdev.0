From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: Notifier chains bug ?
Date: Thu, 4 Mar 2010 18:08:07 +0800
Message-ID: <2375c9f91003040208g1c66f1eft6c2c1044ed995c4e@mail.gmail.com>
References: <4B8C56F0.5090700@gmail.com>
	 <2375c9f91003011924k43f03649y5b4df405d6247a79@mail.gmail.com>
	 <5e9821061003012150y15e543cdkf6f23c3a7a47e4a3@mail.gmail.com>
	 <20100302153651.GC4014@hack>
	 <7f9bf5711003020755p653a0b8cq707e9b1e12b44c98@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oleg Kutkov <elenbert@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Atis Elsts <atis.elsts@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7f9bf5711003020755p653a0b8cq707e9b1e12b44c98@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 2, 2010 at 11:55 PM, Atis Elsts <atis.elsts@gmail.com> wrot=
e:
> I'm no expert, but IMHO for handling IP address changes you should us=
e
> function register_inetaddr_notifier() to register you callback and
> then wait for =C2=A0NETDEV_UP and NETDEV_DOWN events.
>

Oh, I think you are right.

Btw, please don't drop Cc's.

Thanks.
