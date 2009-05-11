From: Michal Soltys <soltys@ziu.info>
Subject: Re: [PATCH/RFC 0/2] HFSC & Stab documentation
Date: Mon, 11 May 2009 16:32:09 +0200
Message-ID: <4A0836E9.6080506@ziu.info>
References: <cover.1235685021.git.soltys@ziu.info> <200904302304.36693.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:4730 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752255AbZEKOxs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 10:53:48 -0400
In-Reply-To: <200904302304.36693.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko wrote:
> Is there any chances that this patches will go to mainstream?
> 
> On Friday 27 February 2009 01:01:30 Michal Soltys wrote:
>> These patches add documentation for HFSC scheduler
>> and size tables. See patch covers for detailed info.
>>
>> Michal Soltys (2):
>>   HFSC (7) & (8) documentation + assorted changes
>>   Stab documentation + assorted changes
>>

I'll adjust/expand this a bit, and repost as v2.

Particulary:

- move hfsc's section about timers to a separate man page, so it can be 
referenced by other man pages (tbf, htb, ...) where it's important, in 
future

- expand stab into both stab/rtab; I'll refrain from changing the 
calculation as well, as it's minor and irrelevant

Still, if for some reason that documentation with cli help related 
changes is not acceptable for any formal and/or content-related reasons, 
it would be good to know that beforehand.

