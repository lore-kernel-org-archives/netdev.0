From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/2] ipv6: allow temporary address
 management for user-created addresses
Date: Mon, 11 Nov 2013 22:04:04 +0100
Message-ID: <20131111210404.GB2397@minipsycho.orion>
References: <1384181359-23199-1-git-send-email-jiri@resnulli.us>
 <20131111.134243.26261596699898567.davem@davemloft.net>
 <20131111194901.GA2397@minipsycho.orion>
 <20131111.150152.1112137216301137879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:63970 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab3KKVEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 16:04:10 -0500
Received: by mail-ee0-f52.google.com with SMTP id l10so988817eei.25
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 13:04:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131111.150152.1112137216301137879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 11, 2013 at 09:01:52PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 11 Nov 2013 20:49:01 +0100
>
>> Mon, Nov 11, 2013 at 07:42:43PM CET, davem@davemloft.net wrote:
>>>
>>>I'm not really going to read patches not properly at least CC:'d to
>>>netdev, sorry Jiri.
>> 
>> netdev is in "To:"
>> 
>> I marked the patches as "RFC" on patchwork. Maybe I should not do it
>> next time, right?
>
>I think you sent this multiple times, once without netdev in the CC: and
>then again with it present.
>
>In any event you did the right thing in the end, sorry about that :)

Nope, I sent this only once.

Anyway, should I touch the state in netdev patchwork or should I always
leave that to you?

I'm used to set "changes requested" before I send another patch version
and "RFC" when I send RFC patch.

Thanks.

Jiri
