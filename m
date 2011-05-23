From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: 2.6.38.x, 2.6.39 =?UTF-8?Q?sfq=3F=20kernel=20panic=20in=20sfq?=  =?UTF-8?Q?=5Fenqueue?=
Date: Tue, 24 May 2011 01:35:08 +0300
Message-ID: <d3a37593d507f6e16c4e7cbf121cdd6b@visp.net.lb>
References: <598fe111e91c6236b8bfdfca323b9a17@visp.net.lb>
 <1306153938.20687.2.camel@edumazet-laptop>
 <1306155058.20687.8.camel@edumazet-laptop>
 <47b6835144d208dca4c6675f6510fcad@visp.net.lb>
 <1306163146.20687.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <hadi@cyberus.ca>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:45055 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752639Ab1EWWfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 18:35:12 -0400
In-Reply-To: <1306163146.20687.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Mon, 23 May 2011 17:05:46 +0200, Eric Dumazet wrote:
> Le lundi 23 mai 2011 =C3=A0 17:27 +0300, Denys Fedoryshchenko a =C3=A9=
crit :
>
>> > Thanks !
>>  By objdump or he must recompile kernel with DEBUG_INFO and use gdb?
>>
>>
>>
>
>
> Just objdump of sch_sfq.o (or sch_sfq.ko) file, (to keep existing
> offsets), thanks
 Sorry for delay, i had to contact person who run that kernel :)

 www.nuclearcat.com/files/disasm.txt
 www.nuclearcat.com/files/sch_sfq.ko


