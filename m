From: Alexey Andrianov <alan@al-an.info>
Subject: Re: [net-next 2/2] ip6_tunnel: allow to change mode for the ip6tnl0
Date: Tue, 21 Oct 2014 19:46:16 +0400
Message-ID: <54467FC8.4020103@al-an.info>
References: <1413879088-13513-1-git-send-email-alan@al-an.info> <1413879088-13513-2-git-send-email-alan@al-an.info> <5446780C.7070004@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward8l.mail.yandex.net ([84.201.143.141]:60080 "EHLO
	forward8l.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755271AbaJUPqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 11:46:22 -0400
In-Reply-To: <5446780C.7070004@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No, you're right. My fault is I missed the cover letter explaining that=
=20
both patches together are overkill. One should be enough. It could be=20
the 1st, but it may cause some compatibility issues. So the maintainer=20
could choose either the second or both.

And I'm really sorry for duplicate messages.

21.10.2014 19:13, Nicolas Dichtel wrote:
> Le 21/10/2014 10:11, Alexey Andriyanov a =C3=A9crit :
>> The fallback device is in ipv6 mode by default.
> After patch 1/2, this is not true. Am I missing something?

--=20
Best regards,
Alexey
