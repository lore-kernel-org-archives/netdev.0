From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 1/6] restructure of_phy_register_fixed_link() for further
 modifications
Date: Thu, 26 Mar 2015 23:26:17 +0300
Message-ID: <55146B69.2050504@list.ru>
References: <55142C31.5050504@list.ru> <55142CB1.1080107@list.ru> <55145794.9090608@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp27.mail.ru ([94.100.181.182]:41461 "EHLO smtp27.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751552AbbCZU0j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 16:26:39 -0400
In-Reply-To: <55145794.9090608@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

26.03.2015 22:01, Sergei Shtylyov =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Hello.
>
> On 03/26/2015 06:58 PM, Stas Sergeev wrote:
>
>> -=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D# Don't remove this line #=3D-=3D=
-=3D-=3D-=3D-=3D-=3D-=3D-=3D-
>
>    Hm, why?
Because I used some stupid thunderbird-patch-inline plugin that
adds that line:
http://www.floc.net/doc/git/contrib/thunderbird-patch-inline/README

> You could have put a proper change log here...
>    Also, threading the patches one after the other is a bad idea,=20
> please post them all as a replies to the patchset summary (0/6).
Ok.

>    Unfortunately, your patch has been whitespace-damaged by your=20
> mailer, with all tabs converted to spaces.
So the plugin didn't work as expected. :(
