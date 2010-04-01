From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next-2.6 PATCH] netfilter: ctnetlink: compute message size
 properly
Date: Thu, 1 Apr 2010 12:43:57 +0200
Message-ID: <20100401104356.GD2879@psychotron.redhat.com>
References: <20100331151102.GB8043@psychotron.lab.eng.brq.redhat.com>
 <4BB38A8A.9050501@trash.net>
 <20100331182116.GB2822@psychotron.redhat.com>
 <1270060543.1931.20.camel@edumazet-laptop>
 <4BB47817.4060902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	davem@davemloft.net, Krzysztof Oledzki <ole@ans.pl>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12531 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758046Ab0DAQdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 12:33:47 -0400
Content-Disposition: inline
In-Reply-To: <4BB47817.4060902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 01, 2010 at 12:40:23PM CEST, kaber@trash.net wrote:
>Eric Dumazet wrote:
>> Le mercredi 31 mars 2010 =E0 20:21 +0200, Jiri Pirko a =E9crit :
>>> Okay, I see your point. How about this:
>>>
>>> Subject: [net-next-2.6 PATCH] netfilter: ctnetlink: compute message=
 size properly V2
>>>
>>> Message size should be dependent on net->ct.sysctl_acct, not on
>>> CONFIG_NF_CT_ACCT definition.
>>>
>>=20
>> Then Changelog is not updated with the actual test :)
>
>I've fixed up the changelog and applied the patch, thanks.

Cand I ask on which tree?

thanks

Jirka
