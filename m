From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 PATCH] netfilter: ctnetlink: compute message size
 properly
Date: Thu, 01 Apr 2010 12:40:23 +0200
Message-ID: <4BB47817.4060902@trash.net>
References: <20100331151102.GB8043@psychotron.lab.eng.brq.redhat.com>	 <4BB38A8A.9050501@trash.net>  <20100331182116.GB2822@psychotron.redhat.com> <1270060543.1931.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	davem@davemloft.net, Krzysztof Oledzki <ole@ans.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1270060543.1931.20.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le mercredi 31 mars 2010 =E0 20:21 +0200, Jiri Pirko a =E9crit :
>> Okay, I see your point. How about this:
>>
>> Subject: [net-next-2.6 PATCH] netfilter: ctnetlink: compute message =
size properly V2
>>
>> Message size should be dependent on net->ct.sysctl_acct, not on
>> CONFIG_NF_CT_ACCT definition.
>>
>=20
> Then Changelog is not updated with the actual test :)

I've fixed up the changelog and applied the patch, thanks.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
