From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [IPROUTE2 PATCH] Interface group as new ip link option
Date: Tue, 16 Oct 2007 11:33:19 +0200
Message-ID: <4714855F.50904@balabit.hu>
References: <1192521703479-git-send-email-panther@balabit.hu> <11925217031287-git-send-email-panther@balabit.hu> <11925217031728-git-send-email-panther@balabit.hu> <1192521703205-git-send-email-panther@balabit.hu> <47147892.4090801@trash.net>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47147892.4090801@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy =EDrta:
> Laszlo Attila Toth wrote:
>> diff --git a/man/man8/ip.8 b/man/man8/ip.8
>> index c74440a..8e6a9a3 100644
>> --- a/man/man8/ip.8
>> +++ b/man/man8/ip.8
>> @@ -511,6 +511,11 @@ already configured.
>> @@ -1835,3 +1840,6 @@ was written by Alexey N. Kuznetsov and added i=
n=20
>> Linux 2.2.
>> =20
>>  .SH AUTHOR
>>  Original Manpage  by Michail Litvak <mci@owl.openwall.com>
>> +.br
>> +Modified for ZorpOS by Tamas Pal <folti@balabit.hu>
>=20
>=20
> Did you really intend to include this?
>=20

I forgot to cut it off because in ZorpOS (v3.1, which is Sarge-based)=20
the manual page contains this part.
-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
