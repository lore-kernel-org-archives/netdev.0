From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Wed, 29 Aug 2007 16:53:52 +0400
Message-ID: <46D56C60.3060702@bigtelecom.ru>
References: <46D53D9C.5070204@bigtelecom.ru> <20070829113447.GA3575@ff.dom.local> <20070829121408.GB3575@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:54281 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbXH2Mxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 08:53:55 -0400
In-Reply-To: <20070829121408.GB3575@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Wed, Aug 29, 2007 at 01:34:47PM +0200, Jarek Poplawski wrote:
>  =20
>> On 29-08-2007 11:34, Badalian Vyacheslav wrote:
>>    =20
>>> Again crash.  Need more posts of panic or this message have full in=
fo=20
>>> that needed to fix bug?
>>>      =20
> ...
>  =20
>> If it's possible you can try it shortly without e.g. netconsole or
>> even without CONFIG_SMP.
>>    =20
>
> ...or maybe even dare to try something current like 2.6.23-rc4?
>
> Jarek P.
>
>  =20
we have this kernel panic (then delete HTB) at all 2.6.18-x versions.
on older kernel (2.6.x) we have another panic (then delete tc filter)..=
=2E=20
summary we have TC panics 1 year ago ;) Sysctl option "reboot on panic"=
=20
save us. Now we up 2 backup computers and may try any patches to fix=20
this problem.

Also on 2.6.22 have strange dead. Black screen, no response to keyboard=
,=20
no info in netconsole, HardDisk led is stable red. "Black Dead"
