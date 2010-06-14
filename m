From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] ip_frag: Remove some atomic ops
Date: Mon, 14 Jun 2010 16:30:21 +0200
Message-ID: <4C163CFD.3050301@trash.net>
References: <1276506144.2478.40.camel@edumazet-laptop>	 <4C163622.7080003@cn.fujitsu.com> <1276525084.2478.92.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276525084.2478.92.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le lundi 14 juin 2010 =C3=A0 22:01 +0800, Shan Wei a =C3=A9crit :
>  =20
>> [PATCH 1/2] netfilter: defrag: remove one redundant atomic ops
>>
>> Instead of doing one atomic operation per frag, we can factorize the=
m.
>> Reported from Eric Dumazet.
>>
>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>>    =20
>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>  =20

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
