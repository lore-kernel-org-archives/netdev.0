From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: kernel BUG at kernel/timer.c:951!
Date: Fri, 15 Jan 2010 15:46:02 +0100
Message-ID: <4B507FAA.8010007@free.fr>
References: <4B2CD772.1030106@upmc.fr> <4B2D1025.1020106@gmail.com> <4B2E6729.1090102@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bernard Pidoux <bernard.pidoux@upmc.fr>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757797Ab0AOOqV@vger.kernel.org>
In-Reply-To: <4B2E6729.1090102@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jarek,

Congratulation. With your patch I did not see any more kernel panics
since my last post.
I think it should be commited.
Many thanks.

Wishing you a happy new year 2010.

Bernard


Bernard Pidoux a =E9crit :
> Hi Jarek,
>=20
> Your patch seemed to be working well until 2.6.31.6 kernel.
> I did not apply your patch to kernel 2.6.32.
> I agree that this may explain why these kernel panics are back.
> I will apply this patch to 2.6.32.2 and will report the results soon.
> Thanks.
>=20
> Bernard Pidoux
>=20
> Jarek Poplawski a =E9crit :
>> Bernard Pidoux wrote, On 12/19/2009 02:38 PM:
>>
>>> I am experiencing a few kernel panics on my Linux system using 2.6.=
32=20
>>> and 2.6.32.1 kernels
>>> with nosmp.=20
>>
>> Some of these oopses look similarly to those:
>> http://markmail.org/message/scjov36zm2wf2ytv
>>
>> How about this patch I sent you for testing?:
>> http://markmail.org/message/nymi7xyd5c43hyfu
>>
>> Jarek P.
>>
>>
>=20
>=20
