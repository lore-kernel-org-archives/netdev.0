From: WeipingPan <panweiping3@gmail.com>
Subject: Re: [PATCH net-next] net:set valid name before calling ndo_init()
Date: Fri, 13 May 2011 09:21:37 +0800
Message-ID: <4DCC87A1.7050604@gmail.com>
References: <1305207541-13311-1-git-send-email-panweiping3@gmail.com> <1305214382.3795.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305214382.3795.28.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/12/2011 11:33 PM, Eric Dumazet wrote:
> Le jeudi 12 mai 2011 =C3=A0 21:39 +0800, Weiping Pan(=E6=BD=98=E5=8D=AB=
=E5=B9=B3) a =C3=A9crit :
>> From: Pan Weiping<panweiping3@gmail.com>
>>
>> A bug of bonding was invloved by e815d19ffe02bdfda1260949ef2b1806171=
,
>> see example 1 and 2.
>>
> I cant find e815d19ffe02bdfda1260949ef2b1806171 in net-next-2.6
>
> but I do find 1c5cae815d19ffe02bdfda1260949ef2b1806171
It's my bad. It should be 1c5cae815d19ffe02bdfda1260949ef2b1806171
> Please always use following when referring to a commit :
>
> ... in commit 1c5cae815d19 (net: call dev_alloc_name from
> register_netdevice) ...
>
> - just limit to _first_ 12 chars, no need to have full length
> - give the commit title
>
>
Ok, I will change the commit log and resend the patch.

thanks
Weiping Pan
