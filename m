From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Wed, 30 Nov 2011 00:59:34 +0100
Message-ID: <4ED571E6.5000707@ans.pl>
References: <CAF9AA63.1622%ulrich.weber@sophos.com>  <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz>  <4ED4A399.6090709@sophos.com>  <alpine.LNX.2.01.1111291255200.20965@frira.zrqbmnf.qr>  <4ED550E7.1090609@ans.pl> <1322604909.2596.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Ulrich Weber <ulrich.weber@sophos.com>,
	Amos Jeffries <squid3@treenet.co.nz>,
	"sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1322604909.2596.38.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2011-11-29 23:15, Eric Dumazet wrote:
> Le mardi 29 novembre 2011 =C3=A0 22:38 +0100, Krzysztof Ol=C4=99dzki =
a =C3=A9crit :
>
>> But without NAT you have pretty big chance to have the same IPv6
>> *suffix* everywhere, based on you MAC address. In your Home, your Wo=
rk,
>> in a Cafe or in a hotel during your vacations in Portugal. So yes, N=
AT
>> is not a perfect solution but it really helps you privacy.
>>
>
> Good point, but we can change MAC address (use a random one) on most
> NIC, cant we ?

Sure, but the problem is that you first need to know that you should do=
=20
it and you need to be able to do it - think of cell phones, tablets, et=
c.

Best regards,

				Krzysztof Oledzki

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
