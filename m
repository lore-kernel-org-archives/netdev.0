From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: PATCH Question, Firewall mark inherit for ip6_tunnel
Date: Mon, 19 Sep 2011 11:52:26 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D90310A@ESESSCMS0356.eemea.ericsson.se>
References: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903109@ESESSCMS0356.eemea.ericsson.se>,<1316424324.2539.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:44392 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688Ab1ISJzc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 05:55:32 -0400
In-Reply-To: <1316424324.2539.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Eric Dumazet [eric.dumazet@gmail.com]
>Sent: Monday, September 19, 2011 11:25
>To: Hans Schillstr=F6m
>Cc: netdev@vger.kernel.org
>Subject: Re: PATCH Question, Firewall mark inherit for ip6_tunnel
>
>Le lundi 19 septembre 2011 =E0 10:47 +0200, Hans Schillstr=F6m a =E9cr=
it :
>> Hello Eric,
>> For a year ago you send an untested patch to Anders Franzen
>> I think the subject was "not possible to do policy routing for next =
hop on tunnels."
>>
>> The patch have been used since that and it works perfectly,
>> I made some minor changes to reflect the flowi changes.
>>
>> Would it be possible for you to submit that patch, since (I guess) y=
ou are the author
>> I can prepare it if you want.
>> The included patch is for  linux-3.0.4
>>
>> Regards
>> Hans Schillstrom
>
>Hello Hans
>
>Yes, I'll respin this patch on top on net-next, with your "Tested-by"
>signature ;)
>
>Thanks

Thanks Eric,
Do you take care of the user mode  part as well (i.ie ip commad)

Hans
