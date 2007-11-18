From: David <david@unsolicited.net>
Subject: Re: Netfilter: kernel panic with REDIRECT target. (2.6.23 and 2.6.23.8)
Date: Sun, 18 Nov 2007 19:34:56 +0000
Message-ID: <474093E0.3090007@unsolicited.net>
References: <47408BBC.6040608@unsolicited.net> <200711182131.38388.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?SXNtYWlsIETDtm5tZXo=?= <ismail@pardus.org.tr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns01.unsolicited.net ([69.10.132.115]:54278 "EHLO
	ns01.unsolicited.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbXKRTgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 14:36:07 -0500
In-Reply-To: <200711182131.38388.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ismail D=C3=B6nmez wrote:
> Sunday 18 November 2007 Tarihinde 21:00:12 yazm=C4=B1=C5=9Ft=C4=B1:
>  =20
>> I'm (very) far from being firewall configuration expert, but I'm see=
ing
>> a consistent kernel panic when the following rule is triggered.
>>
>>     iptables -t nat -A PREROUTING -j REDIRECT -i eth2 -p udp --dport
>> 5061 --to-ports 5060
>>
>> (I'm trying to redirect an alternate port to a SIP server)
>>
>> Am I just being very stupid, or is there something I'm not seeing he=
re?
>>    =20
>
> Also post the kernel panic log.
>  =20
This is a bit difficult since the server is headless (normally). I can
try to obtain the panic via a temporary console, but it may have to wai=
t
for a day or two.

David
