From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: sfc: an enumeration is not a bitmask
Date: Tue, 17 May 2011 18:00:12 -0400
Message-ID: <4DD2EFEC.9040504@pobox.com>
References: <20110517.141446.140687548350861625.davem@davemloft.net> <BANLkTi=n_0JiF0Lm=+1OwRzB4XQFBtg8KA@mail.gmail.com> <BANLkTinaO0VVGpRRqRauH6FucvwbcXyRUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:46444 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932389Ab1EQWAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 18:00:17 -0400
Received: by gwaa18 with SMTP id a18so333819gwa.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 15:00:16 -0700 (PDT)
In-Reply-To: <BANLkTinaO0VVGpRRqRauH6FucvwbcXyRUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2011 03:09 PM, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/5/17 Jeff Garzik<jgarzik@pobox.com>:
>> 2011/5/17 David Miller<davem@davemloft.net>:
>>> An enumeration is not a bitmask, instead it means one out of the se=
t
>>> of enumerated values will be used.
>>
>> It's a decade-old kernel practice to use 'enum' to define typed
>> constants, preferred over  macros that convey no type information an=
d
>> disappear after cpp phase.
>>
>> So your assertion about enumerations is demonstrably not true, as it
>> is often used in the kernel.  Call it enum abuse if you want, but it
>> is consistent with code all over the kernel.

> Old age of the mistake doesn't make it correct.

It is not a mistake, but a useful coding tool.

	Jeff


