From: Salatiel Filho <salatiel.filho@gmail.com>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Fri, 24 Apr 2009 12:23:48 -0300
Message-ID: <beb91d720904240823lf724b9bo207f4294dc9e4a8d@mail.gmail.com>
References: <20090423084323.GA5696@ff.dom.local> <beb91d720904231632m2a66768dy95f1df1491d97f5b@mail.gmail.com>
	<49F1D16A.8050003@trash.net> <200904241755.09198.denys@visp.net.lb>
	<beb91d720904240814x56a928a5u5345e572c701fa90@mail.gmail.com>
	<49F1D88F.500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"Y. D." <duyuyang@gmail.com>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f118.google.com ([209.85.221.118]:62329 "EHLO
	mail-qy0-f118.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756042AbZDXPYG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 11:24:06 -0400
In-Reply-To: <49F1D88F.500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2009 at 12:19, Patrick McHardy <kaber@trash.net> wrote:
> Salatiel Filho wrote:
>>
>> On Fri, Apr 24, 2009 at 11:55, Denys Fedoryschenko <denys@visp.net.l=
b>
>> wrote:
>>>
>>> On Friday 24 April 2009 17:49:14 Patrick McHardy wrote:
>>>>
>>>> There is DRR since a couple of versions. Combined with the
>>>> flow classifier, it should provide the same functionality
>>>> as ESFQ.
>>>
>>> I think it is even better, as soon as you understand it, it is very
>>> intuitive
>>> to understand and transparent, how it works.
>>>
>>
>> I am just curious , is there a qdisc in mainline that behaves simila=
r
>> to wrr [weight round robin] ?
>> http://www.zz9.dk/wrr
>
> DRR. But it can't do those strange load-balancing hacks.
>

what would it be those strange ugly hacks ? :)
Any good place where i can find DRR documentation/examples ?

--=20
[]'s
Salatiel

"O maior prazer do inteligente =E9 bancar o  idiota
   diante de um  idiota que banca o inteligente".
