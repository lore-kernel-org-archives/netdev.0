From: "Nick Kossifidis" <mickflemm@gmail.com>
Subject: Re: [GIT]: Networking
Date: Mon, 1 Sep 2008 10:19:05 +0300
Message-ID: <40f31dec0809010019x54d14f43ub614f98ec6420ad7@mail.gmail.com>
References: <20080805.190020.244441681.davem@davemloft.net>
	 <alpine.LFD.1.10.0808051937410.15995@nehalem.linux-foundation.org>
	 <200808061021.56150.IvDoorn@gmail.com> <48B7CBA7.4060107@grupopie.com>
	 <40f31dec0808311258q7598dfe3he81b7575375faff5@mail.gmail.com>
	 <alpine.LFD.1.10.0808311313260.12958@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Rui Santos" <rsantos@grupopie.com>,
	"Ivo van Doorn" <ivdoorn@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:13252 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbYIAHTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 03:19:06 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1754428wfd.4
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2008 00:19:05 -0700 (PDT)
In-Reply-To: <alpine.LFD.1.10.0808311313260.12958@nehalem.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/8/31 Linus Torvalds <torvalds@linux-foundation.org>:
>
>
> On Sun, 31 Aug 2008, Nick Kossifidis wrote:
>>
>> EeePC is working, the patch series i submitted adds support for RF2425
>> chip which is included on EeePCs as far as i know (i have tested it on
>> an EeePC 900 surf, i think EeePC 901 has the same card) ;-)
>
> I think the EeePC 900 has a ath5k chip, and the 901/1000 has some totally
> different RaLink chip afaik.
>
> I think the design change came when moving from Celeron to Atom.
>
>                Linus
>

Hmm i missed that part, sorry for the spam...

01:00.0 Network controller: RaLink Unknown device 0781

-- 
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick
