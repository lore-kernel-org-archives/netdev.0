From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH RESEND net-next] ethtool: bring back missing comma in
 netdev features strings
Date: Thu, 12 May 2011 10:59:05 -0700
Message-ID: <BANLkTik2gH_uGgN73+U7HTZ5HPFbBJy7Fg@mail.gmail.com>
References: <20110512164204.EC8391220061@host64.kissl.de>
	<BANLkTikW=vURi7sAQ9ZJdgy=JDv+JacTQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: franco@lastsummer.de, netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:23802 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758223Ab1ELR7J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 13:59:09 -0400
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p4CHx7Ux001445
	for <netdev@vger.kernel.org>; Thu, 12 May 2011 10:59:08 -0700
Received: from bwz18 (bwz18.prod.google.com [10.188.26.18])
	by hpaq14.eem.corp.google.com with ESMTP id p4CHx6q4005404
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 12 May 2011 10:59:06 -0700
Received: by bwz18 with SMTP id 18so2304398bwz.15
        for <netdev@vger.kernel.org>; Thu, 12 May 2011 10:59:06 -0700 (PDT)
In-Reply-To: <BANLkTikW=vURi7sAQ9ZJdgy=JDv+JacTQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2011 at 9:45 AM, Micha=C5=82 Miros=C5=82aw <mirqus@gmai=
l.com> wrote:
> 2011/5/12 =C2=A0<franco@lastsummer.de>:
>> The issue was introduced in commit eed2a12f1ed9aabf.
>>
>> Signed-off-by: Franco Fichtner <franco@lastsummer.de>
>> ---
>> =C2=A0net/core/ethtool.c | =C2=A0 =C2=A02 +-
>> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
>> index b6f4058..b8c2b10 100644
>> --- a/net/core/ethtool.c
>> +++ b/net/core/ethtool.c
>> @@ -361,7 +361,7 @@ static const char
>> netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GS
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* NETIF_F_NTUPLE */ =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0"rx-ntuple-filter",
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* NETIF_F_RXHASH */ =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0"rx-hashing",
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* NETIF_F_RXCSUM */ =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0"rx-checksum",
>> - =C2=A0 =C2=A0 =C2=A0 /* NETIF_F_NOCACHE_COPY */ =C2=A0 =C2=A0"tx-n=
ocache-copy"
>> + =C2=A0 =C2=A0 =C2=A0 /* NETIF_F_NOCACHE_COPY */ =C2=A0 =C2=A0"tx-n=
ocache-copy",
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* NETIF_F_LOOPBACK */ =C2=A0 =C2=A0 =C2=A0=
 =C2=A0"loopback",
>> =C2=A0};
>
> Acked-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
>
 Acked-by: Mahesh Bandewar <maheshb@google.com>
