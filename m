From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] ipfrag : frag_kfree_skb() cleanup
Date: Mon, 14 Jun 2010 16:32:29 +0200
Message-ID: <4C163D7D.2000409@trash.net>
References: <1276507363.2478.43.camel@edumazet-laptop>	 <4C163643.1080906@cn.fujitsu.com> <1276525212.2478.93.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276525212.2478.93.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le lundi 14 juin 2010 =C3=A0 22:01 +0800, Shan Wei a =C3=A9crit :
>  =20
>> [PATCH 2/2] netfilter: defrag: kill unused work parameter of frag_kf=
ree_skb()
>>
>> The parameter (work) is unused, remove it.
>> Reported from Eric Dumazet.
>>
>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>>    =20
>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>
>  =20
Also applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
