From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Thu, 25 Mar 2010 10:28:20 +0800
Message-ID: <4BAACA44.6010306@cn.fujitsu.com>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4BA8D8AF.1040307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BA8D8AF.1040307@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote, at 03/23/2010 11:05 PM:
> Shan Wei wrote:
>>> On the other hand, I'd even say we should NOT send
>>> icmp here (at least by default) because standard routers
>>> never send such packet.
>>>    =20
>> Yes=EF=BC=8Cfor routers, the patch-set does not send icmp message to
>> source host. It only does on destination host with IPv6 connection=20
>> track enable.
>>  =20
>=20
> The nf-next tree is open again, now would be a good time to resubmit
> these patches.
> Thanks!

If no body opposes them, i will resubmit these patches with v3.=20

--=20
Best Regards
-----
Shan Wei
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
