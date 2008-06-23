From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] hfsc: add link layer overhead adaption
Date: Mon, 23 Jun 2008 21:37:37 +0200
Message-ID: <485FFB81.5000804@trash.net>
References: <20080623102514.15821.13979.stgit@fate.lan>	<485F81B2.7000107@trash.net> <20080623142417.9gxuu3y9r4084s4c@hayate.ip6>	<485F889E.1050901@trash.net> <20080623221522.jqh110t8o4cgss4o@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60194 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbYFWThl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 15:37:41 -0400
In-Reply-To: <20080623221522.jqh110t8o4cgss4o@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> Quoting Patrick McHardy <kaber@trash.net>:
> 
>>>
>>> So would it be better if I add 'length table' to kernel&userspace  
>>> and use it instead?
>>
>> Yes, I even posted an unfinished patch for this one or two years
>> ago, in response to the overhead calculation patches for HTB etc.
>>
>> I can't find it right now, but haven't tried too hard. It was
>> called qdisc STABs (for size tables), you should be able to find
>> it in the archives.
> 
> Well, my LTAB didn't end up being exactly same your earlier STAB, but I 
> renamed LTAB to STAB as it sounds better. Hope you don't mind :]

Not at all :) Did you already post that patch?
